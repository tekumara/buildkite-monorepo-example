# buildkite-monorepo-example

Example [Makefile](Makefile) that determines which directories have changes since the last known good build tag.

Each directory corresponds to a Make target, which typically is a shared library or application.
 
When a change is detected the corresponding Make target is run, which triggers the relevant build pipeline (eg: [app1/.buildkite/pipeline.yml](app1/.buildkite/pipeline.yml)). Alternatively, you may want to swap that out for immediately running your build if you don't need any additional pipeline steps (eg: a [block step](https://buildkite.com/docs/pipelines/block-step)).

Dependencies can be expressed as dependent Make targets.

Currently adds around ~1 min to the total build time, roughly 30 secs to upload the [initial triggering pipeline](.buildkite/pipeline.yml), 20s to run the Makefile (which triggers the child pipelines dynamically) and then 30s to `git tag` the build after. There might be some ways to optimise this?
