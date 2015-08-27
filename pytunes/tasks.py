from invoke import Collection, run, ctask, task

@ctask
def clean(ctx):
    ctx.run('rm -rf build dist')

@ctask
def test(ctx):
    ctx.run('tox -e test-py27,test-py34')

@ctask
def docs(ctx):
    ctx.run('tox -e docs')

@ctask(docs)
def serve_docs(ctx):
    ctx.run('caddy -port=9999 -root=build/doc')

@ctask
def flake8(ctx):
    ctx.run('tox -e flake8')

@ctask
def dist(ctx):
    ctx.run('tox -e dist-py27,dist-py34')
