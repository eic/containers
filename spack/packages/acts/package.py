from spack.pkg.builtin.acts import Acts as BuiltinActs
class Acts(BuiltinActs):
    version('19.1.0', commit='82f42a2cc80d4259db251275c09b84ee97a7bd22', submodules=True)
