#!/usr/bin/env python3

import os
import sys
import yaml
import argparse
import subprocess
from datetime import datetime

DETECTOR_REPO_GROUP = 'https://github.com/eic'
DETECTOR_ENV ='''
#!/bin/sh
export DETECTOR={detector}
export DETECTOR_PATH={data_prefix}
export DETECTOR_CONFIG={detector}
export DETECTOR_VERSION={version}

## Export detector libraries
export LD_LIBRARY_PATH={prefix}/lib${{LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}}

## modify PS1 for this detector version
export PS1="${{PS1:-}}"
export PS1="{branch}${{PS1_SIGIL}}>${{PS1#*>}}"
unset branch
'''

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
            '-p', '--prefix',
            dest='prefix',
            default='/opt/detector',
            help='Main detector prefix')
    parser.add_argument(
            '-c', '--config',
            dest='config',
            default='detectors.yaml',
            help='Detector configuration file')
    parser.add_argument('--nightly', action='store_true', dest='nightly', 
            help='Store nightly snapshot (will also be set as default)')
    args = parser.parse_args()

    print('Installing detector configuration from {} to {}'.format(args.config,
        args.prefix))
    if args.nightly:
        print(' --> Nightly requested, will default configurations to nightly')
    else:
        print(' --> Regular run, nightly snapshot will NOT be installed')

    print(' --> Loading detector configuration')
    default_found = False
    default_detector = ''
    default_version = ''
    with open(args.config) as f:
        data=yaml.load(f, Loader=yaml.FullLoader)
        detectors=data['detectors']
        for det in detectors:
            if not args.nightly and 'nightly' in detectors[det]:
                del detectors[det]['nightly']    
            for branch in detectors[det]:
                cfg = detectors[det][branch]
                default_str = ''
                if not default_found:
                    if args.nightly and branch == 'nightly':
                        default_str = ' (default)'
                        default_detector = det
                        default_version = 'nightly'
                        default_found = True
                    elif not args.nightly and 'default' in cfg and cfg['default']:
                        default_str = ' (default)'
                        default_detector = det
                        default_version = cfg['version']
                        default_found = True
                print('    - {}: {}{}'.format(det, branch, default_str))
    print(' --> Building and installing detector libraries')
    process_list = []
    for det in detectors:
        if not args.nightly and 'nightly' in detectors[det]:
            del detectors[det]['nightly']    
        for branch in detectors[det]:
            cfg = detectors[det][branch]
            version = cfg['version'] if branch != 'nightly' else 'nightly'
            prefix = '{}/{}-{}'.format(args.prefix, det, version)
            data_dir = '{}/share/{}'.format(prefix, det)
            ## build and install
            print('    - {}-{}'.format(det, cfg['version']))
            ## clone/build/install detector libraries
            cmd = ['rm -rf /tmp/build /tmp/det',
                    '&&',
                    'git clone --depth 1 -b {version} {repo_grp}/{detector}.git /tmp/det'.format(
                        version=cfg['version'], 
                        repo_grp=DETECTOR_REPO_GROUP,
                        detector=det),
                    '&&',
                    'cmake -B /tmp/build -S /tmp/det -DCMAKE_CXX_STANDARD=17',
                    '-DCMAKE_CXX_FLAGS="-Wno-psabi"',
                    '-DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache',
                    '-DCMAKE_INSTALL_PREFIX={prefix}'.format(prefix=prefix),
                    '&&',
                    'cmake --build /tmp/build -j$(($(($(nproc)/4))+1)) -- install']
            print(' '.join(cmd))
            subprocess.check_call(' '.join(cmd), shell=True)
            ## write version info to jug_info if available
            if os.path.exists('/etc/jug_info'):
                cmd = ['cd /tmp/det',
                        '&&',
                        'echo " - {detector}/{branch}: {version}-$(git rev-parse HEAD)"'.format(
                            detector=det,
                            branch=branch,
                            version=cfg['version']),
                        '>> /etc/jug_info',
                        '&&',
                        'cd -']
                print(' '.join(cmd))
                subprocess.check_call(' '.join(cmd), shell=True)
            ## cleanup
            cmd = 'rm -rf /tmp/det /tmp/build'
            print(cmd)
            subprocess.check_call(cmd, shell=True)
            # be resilient against failures
            if os.path.exists(prefix):
                ## create a shortcut for the prefix if desired
                if branch != version:
                    cmd = 'rm -rf {shortcut} && ln -sf {prefix} {shortcut}'.format(
                                prefix=prefix,
                                shortcut='{}/{}-{}'.format(args.prefix, det, branch))
                    print(cmd)
                    subprocess.check_call(cmd, shell=True)
                ## write an environment file for this detector
                with open('{prefix}/setup.sh'.format(prefix=prefix), 'w') as f:
                    print(DETECTOR_ENV.format(
                        prefix=prefix,
                        detector=det,
                        data_prefix=data_dir,
                        version=cfg['version'],
                        branch=branch),
                        file=f)
                ## run once inside global prefix to initialize artifacts in /opt/detectors
                os.environ['DETECTOR_PATH'] = args.prefix
                cmd = f'cd {args.prefix} && source {prefix}/setup.sh && checkGeometry -c {prefix}/share/{det}/{det}.xml'
                print(cmd)
                process_list.append(subprocess.Popen(cmd, shell=True, executable='/bin/bash', stdout=subprocess.PIPE, stderr=subprocess.STDOUT))
                ## run once inside specific prefix to initialize artifacts in $DETECTOR_PATH
                os.environ['DETECTOR_PATH'] = args.prefix
                cmd = f'cd {prefix}/share/{det} && source {prefix}/setup.sh && checkGeometry -c {prefix}/share/{det}/{det}.xml'
                print(cmd)
                process_list.append(subprocess.Popen(cmd, shell=True, executable='/bin/bash', stdout=subprocess.PIPE, stderr=subprocess.STDOUT))

    while len(process_list) > 0:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("{} processes running... ({})".format(len(process_list), current_time))
        (out, err) = process_list[-1].communicate()
        if process_list[-1].wait() != 0:
            print(process_list[-1].args)
            if out is not None:
                print("stdout:")
                print(out.decode())
            if err is not None:
                print("stderr:")
                print(err.decode())
            sys.exit(1)
        process_list.pop()

    if not default_found and not args.nightly:
        # Skip symlinking if no defaults present and its not a nightly build
        pass
    else:
        print(' --> Symlinking default detector for backward compatibility')
        full_prefix='{}/{}-{}'.format(args.prefix, default_detector, default_version)
        cmd = ['ln -sf {full_prefix}/share {short_prefix}',
            '&&',
            'ln -sf {full_prefix}/lib {short_prefix}',
            '&&',
            'ln -sf {full_prefix}/setup.sh {short_prefix}']
        print(' '.join(cmd))
        subprocess.check_call(' '.join(cmd).format(full_prefix=full_prefix, short_prefix=args.prefix), shell=True)

    print('All done!')
