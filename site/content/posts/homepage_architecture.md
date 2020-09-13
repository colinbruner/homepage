+++
title = "Homepage Architecture"

[taxonomies]
tags = ["Personal", "IT Infrastructure"]
+++

## Intro
Having a website to express yourself is nice, but one of the more interesting
aspects of this to me was designing the architecture using DNS and Cloud services.

I realize there are many hosted static website services available these days,
such as Netlify, but those wouldn't have been as fun for me to set up.

## Diagram
Like the beginning of any good fantasy book, the story is only enhanced by a
picture or map detailing the landscape prior to beginning.
{{ drawio() }}

## Services
I began with a few critical AWS services:
- Elastic Load Balancing
- AWS Fargate
- AWS S3

I host my domain on CloudFlare and created a CNAME record for the root of my 
domain, colinbruner.com, to the DNS name of my AWS load balancer object. I 
then add a second CNAME for a [develop][1] subdomain pointed at the same AWS 
load balancer.

The AWS Elastic Load Balancer (ELB) will receive the forwarded requests from 
CloudFlare and map them to an AWS target group associated to the ELB.

The target group contains three container tasks running in an AWS Elastic
Container Service (ECS) Fargate cluster. The containers are very simple 
NGINX proxys intended to handle the mapping of the requests to the appropriate
S3 static website directory. More on that later.

## NGINX

{{ gist(url="https://gist.github.com/colinbruner/6a5ec95a0589081c9de2a7c9ea1267e8") }}

As you can see above, I'm using a conditional based off of the requesting URL and the proxy_pass 
directive to forward the request onto the correct S3 directory. This enables me to use the 
[develop][1] subdomain to view my changes in PROD before merging into the master branch
and allowing the CI/CD process to deploy the changes.

## CI/CD
I'm using [CircleCI][2] to build and deploy my website with a few lines of 
straightforward YAML. As defined in my [config][3], I'm doing the following within two 
shell scripts.
- Installing necessary dependencies and genearting this website using [Zola][4].
- Sync assets to an S3 directory matching the active git branch in my S3 bucket.

This combined with the CNAME redirection to the 'develop' subdomain provide an
easy near-live preview to any changes I'm looking to deploy.

[1]: https://develop.colinbruner.com
[2]: https://circleci.com
[3]: https://github.com/colinbruner/homepage/blob/develop/.circleci/config.yml
[4]: https://getzola.org
