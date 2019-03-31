# buildkite-monorepo-example

Example [Makefile](Makefile) that determines which directories have changes since the last known good build tag.

Each directory corresponds to a Make target, which typically is a shared library or application.
 
When a change is detected the corresponding Make target is run, which triggers the relevant child build pipeline (eg: [app1/.buildkite/pipeline.yml](app1/.buildkite/pipeline.yml)). Alternatively, you may want to swap that out for immediately running your build if you don't need any additional pipeline steps (eg: a [block step](https://buildkite.com/docs/pipelines/block-step)).

Dependencies can be expressed as dependent Make targets.

Currently adds around ~1 min to the total build time, roughly 30 secs to upload the [initial triggering pipeline](.buildkite/pipeline.yml), 20s to run the Makefile (which triggers the child pipelines dynamically) and then 30s to `git tag` the build after. There might be some ways to optimise this?

## Change detection

In a monorepo you generally only want to build what has changed. Build tools like Bazel do this by using comparing against a build cache to determine which source files have changed.

This monorepo uses git to detect changes, in order to work with any build tool. The cases handled are:

1) building a branch which has master as an ancestor - to do this we can compare the branch to master, and determine which subdirectories have changed and run targets for them. This requires that master is up-to-date on the buildkite agent, but buildkite doesn't fetch master on every build (only when it first clones the repo).
2) building a commit merged to master - to do this we need to know the previous commit of master we built

In both cases we need a commit on master to compare to. The solution used here is to create a git tag `last-good-master-build` to record the last successful build on master. Note that tagging the git repo after a successful build (ie: `make tag-last-good-master-build`) requires that the buildkite agent has an SSH key with write access.

Note that if you aren't branching directly off master, but off another branch, then we will rebuild changes all the way back to master.
  
## Setup

Using the buildkite UI, you'll then need to manually create individual pipelines for each child pipeline you have. The upload step of the child pipeline will need to reference `pipeline.yml` in the appropriate `.buildkite` subdirectory, eg: for the `app1` pipeline
```
buildkite-agent pipeline upload app1/.buildkite/pipeline.yml
```


