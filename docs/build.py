import os

from markdown import Markdown
from mako.template import Template

here = os.path.dirname(os.path.abspath(__file__))

markdown = Markdown(
    extensions=['headerid', 'meta', 'extra', 'codehilite', 'toc'],
    extension_configs={
        'codehilite': [
            ('linenums', False),
            ('guess_lang', False),
        ],
        'toc': [
            ('title', 'Table of Contents'),
            ('permalink', True),
        ]
    }
)
template = Template(filename=os.path.join(here, 'layout.mako'),
                    output_encoding='utf-8')
with open(os.path.join(here, 'index.md')) as f:
    source = f.read().decode('utf-8')

with open(os.path.join(here, '..', 'CHANGES.md')) as f:
    source += '\n' + f.read().decode('utf-8')

with open(os.path.join(here, '..', 'VERSION.txt')) as f:
    version = f.read().decode('utf-8')

body = markdown.convert(source)
meta = markdown.Meta
meta['version'] = version

with open(os.path.join(here, 'www', 'index.html'), 'w') as f:
    f.write(template.render(body=body, meta=meta))
