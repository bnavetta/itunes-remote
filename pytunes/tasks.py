from invoke import Collection, run, ctask, task
import docs

@task(docs.clean)
def clean():
    pass

@ctask
def test(ctx):
    ctx.run('tox')

namespace = Collection(docs, clean, test)
