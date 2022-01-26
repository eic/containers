from spack.pkg.builtin.acts import Acts as BuiltinActs
class Acts(BuiltinActs):
    version('16.0.0', commit='9bd86921155e708189417b5a8019add10fd5b273', submodules=True)
    version('15.1.0', commit='a96e6db7de6075e85b6d5346bc89845eeb89b324', submodules=True)
    version('15.0.0', commit='0fef9e0831a90e946745390882aac871b211eaac', submodules=True)
