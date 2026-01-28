I wasn't sure about how actually test & discover .yaml files of resources
specifically rustfs k8s deployment 
and I encounter this 'command pattern' or 'template' very useful:
`curl -L <URL> > [filename].yaml`
and I also create a `tests/` directory for testing and discovery interactions like this
