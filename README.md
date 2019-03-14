# buildkite-monorepo-example

Example [Makefile](Makefile) that determines which directories have changes since the last known good build tag.

Each directory corresponds to a Make target, which typically is a shared library or application.
 
When a change is detected the corresponding Make target is run, which triggers the relevant child build pipeline (eg: [app1/.buildkite/pipeline.yml](app1/.buildkite/pipeline.yml)). Alternatively, you may want to swap that out for immediately running your build if you don't need any additional pipeline steps (eg: a [block step](https://buildkite.com/docs/pipelines/block-step)).

Dependencies can be expressed as dependent Make targets.

Currently adds around ~1 min to the total build time, roughly 30 secs to upload the [initial triggering pipeline](.buildkite/pipeline.yml), 20s to run the Makefile (which triggers the child pipelines dynamically) and then 30s to `git tag` the build after. There might be some ways to optimise this?

## Setup

Before using this on a new repo, run `make tag-last-good-master-build` first to create the last good master build tag (and on first run expect to see the error `fatal: ambiguous argument 'last-good-master-build': unknown revision or path not in the working tree.`)

Using the buildkite UI, you'll then need to manually create individual pipelines for each child pipeline you have. The upload step of the child pipeline will need to reference `pipeline.yml` in the appropriate `.buildkite` subdirectory, eg: for the `app1` pipeline
```
buildkite-agent pipeline upload app1/.buildkite/pipeline.yml
```
