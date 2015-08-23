from invoke import ctask, run

@ctask
def build(ctx):
    ctx.run('sphinx-apidoc -o doc src -H pytunes -f')
    ctx.run('sphinx-build -b html -d build/doctrees doc build/doc')

@ctask
def clean(ctx):
    ctx.run('rm -rf build/doctrees')
    ctx.run('rm -rf build/doc')

@ctask
def serve(ctx):
    ctx.run('caddy -port=9999 -root=build/doc')
