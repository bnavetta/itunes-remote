import ssl

from itunes_server import app

def create_ssl_context():
    cert = app.config['SSL_CERT']
    key = app.config['SSL_KEY']

    # context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
    context.options = ssl.OP_NO_SSLv2 | ssl.OP_NO_SSLv3
    context.load_cert_chain(certfile=cert, keyfile=key)
    return context
