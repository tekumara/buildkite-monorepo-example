# buildkite-monorepo-example

Example [Makefile](Makefile) that determines which directories have changes since the last known good build tag.

Each directory corresponds to a build target, which typically is a shared library or application.
 
When a change is detected the corresponding Make target is run, which triggers the relevant build pipeline but you may want to swap that out for immediately running your build if you don't need any additional pipeline steps (eg: a [block step](https://buildkite.com/docs/pipelines/block-step)).

Dependencies can be expressed as dependent Make targets.
