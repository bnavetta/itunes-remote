import hug

@hug.get('/hello/{name}')
def hello(name, punctuation='!'):
    return "Hello, {name}{punctuation}".format(**locals())
