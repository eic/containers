#!/usr/bin/env python3

import os
import yaml
import argparse

DETECTOR_REPO_GROUP = 'https://eicweb.phy.anl.gov/EIC/detectors'
DETECTOR_ENV ='''
#!/bin/sh
export DETECTOR={detector}
export DETECTOR_PATH={data_prefix}
export DETECTOR_VERSION={version}
export BEAMLINE_CONFIG={ip}
export BEAMLINE_CONFIG_VERSION={ip_version}
## note: we will phase out the JUGGLER_* flavor of variables in the future
export JUGGLER_DETECTOR=$DETECTOR
export JUGGLER_DETECTOR_VERSION=$DETECTOR_VERSION
export JUGGLER_DETECTOR_PATH=$DETECTOR_PATH
export JUGGLER_BEAMLINE_CONFIG=$BEAMLINE_CONFIG
export JUGGLER_BEAMLINE_CONFIG_VERSION=$BEAMLINE_CONFIG_VERSION
export JUGGLER_INSTALL_PREFIX=/usr/local

## modify PS1 for this detector version
export PS1="${{PS1}}"
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
    print(' --> Building and installing detector/ip libraries')
    for det in detectors:
        if not args.nightly and 'nightly' in detectors[det]:
            del detectors[det]['nightly']    
        for branch in detectors[det]:
            cfg = detectors[det][branch]
            ip = cfg['ip']
            version = cfg['version'] if branch != 'nightly' else 'nightly'
            print('    - {}-{} and {}-{}'.format(
            det, cfg['version'], ip['config'], ip['version']))
            prefix = '{}/{}-{}'.format(args.prefix, det, version)
            data_dir = '{}/share/{}'.format(prefix, det)
            ## build and install detector and IP code
            for (proj, vers) in [(det, cfg['version']), (ip['config'], ip['version'])]:
                ## clone/build/install detector libraries
                cmd = ['rm -rf /tmp/build /tmp/det',
                       '&&',
                       'git clone --depth 1 -b {version} {repo_grp}/{detector}.git /tmp/det'.format(
                            version=vers, 
                            repo_grp=DETECTOR_REPO_GROUP,
                            detector=proj),
                       '&&',
                       'cmake -B /tmp/build -S /tmp/det -DCMAKE_CXX_STANDARD=17',
                       '-DCMAKE_INSTALL_PREFIX={prefix}'.format(prefix=prefix),
                       '&&',
                       'cmake --build /tmp/build -j$((($(nproc)/4)+1)) -- install']
                print(' '.join(cmd))
                os.system(' '.join(cmd))
                ## write version info to jug_info if available
                if os.path.exists('/etc/jug_info'):
                    cmd = ['cd /tmp/det',
                           '&&',
                           'echo " - {detector}/{branch}: {version}-$(git rev-parse HEAD)"'.format(
                               detector=proj,
                               branch=branch,
                               version=cfg['version']),
                           '>> /etc/jug_info',
                           '&&',
                           'cd -']
                    print(' '.join(cmd))
                    os.system(' '.join(cmd))
                ## also copy over IP configuration to the detector
                if os.path.exists('/tmp/det/{ip}'.format(ip=ip['config'])):
                    cmd = 'cp -r /tmp/det/{ip} {data_dir}'.format(
                                    ip=ip['config'], data_dir=data_dir)
                    print(cmd)
                    os.system(cmd)
                ## cleanup
                cmd = 'rm -rf /tmp/det /tmp/build'
                print(cmd)
                os.system(cmd)
            # be resilient against failures
            if os.path.exists(prefix):
                ## create a shortcut for the prefix if desired
                if branch != version:
                    cmd = 'rm -rf {shortcut} && ln -sf {prefix} {shortcut}'.format(
                                prefix=prefix,
                                shortcut='{}/{}-{}'.format(args.prefix, det, branch))
                    print(cmd)
                    os.system(cmd)
                ## write an environment file for this detector
                with open('{prefix}/setup.sh'.format(prefix=prefix), 'w') as f:
                    print(DETECTOR_ENV.format(
                            detector=det,
                            data_prefix=data_dir,
                            version=cfg['version'],
                            ip=ip['config'],
                            ip_version=ip['version'],
                            branch=branch),
                          file=f)
    print(' --> Symlinking default detector for backward compatibility')
    full_prefix='{}/{}-{}'.format(args.prefix, default_detector, default_version)
    cmd = ['ln -sf {full_prefix}/share {short_prefix}',
           '&&',
           'ln -sf {full_prefix}/lib {short_prefix}',
           '&&',
           'ln -sf {full_prefix}/setup.sh {short_prefix}']
    print(' '.join(cmd))
    os.system(' '.join(cmd).format(full_prefix=full_prefix, short_prefix=args.prefix))

    print('All done!')










            
