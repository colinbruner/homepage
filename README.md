# Homepage
The following is the content for colinbruner.com

# Local Development
Statically generated with `zola`, from this directory run the following to serve
with active reload.

```bash
$ zola serve
```

# Building / Deploying
Building and deploying the static site is done with `./scripts/build.sh`. 

Ensure AWS_PROFILE is correct and run the following:
```bash
# To deploy to dev endpoint
$ ZOLA_ENV=development ./scripts/build.sh

# To deploy to prod endpoint
$ ./scripts/build.sh
```

# Credit

Theme credit to the Zola's [Sam Theme][https://github.com/trevordmiller/zola-sam]
