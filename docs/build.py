import os

from markdown import Markdown
from mako.template import Template

here = os.path.dirname(os.path.abspath(__file__))

markdown = Markdown(extensions=['headerid', 'meta', 'codehilite'])
template = Template(filename=os.path.join(here, 'layout.mako'))
with open(os.path.join(here, 'index.md')) as f:
    source = f.read()

body = markdown.convert(source)
meta = markdown.Meta

with open(os.path.join(here, 'index.html'), 'w') as f:
    f.write(template.render(body=body, meta=meta))
