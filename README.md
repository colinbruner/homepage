# Homepage

A personal website to mess around with and practice deploying to a k3s raspberry pi cluster.

## Notes
The prod container expects certificates to be mounted in /etc/nginx/secrets for the nginx 
process... this is accomplished through k3s volume mounts.

## Credits
Written using Zola and the [Sam Theme][st]

[st]: https://www.getzola.org/themes/sam/
