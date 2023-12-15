# Changelog

## [1.0.1](https://github.com/nvim-java/nvim-java-core/compare/v1.0.0...v1.0.1) (2023-12-15)


### Bug Fixes

* lombok is not working ([#48](https://github.com/nvim-java/nvim-java-core/issues/48)) ([9538926](https://github.com/nvim-java/nvim-java-core/commit/9538926d14396eede8fc0d625761c9ed659c96df))

## 1.0.0 (2023-12-10)


### ⚠ BREAKING CHANGES

* move dap APIs to nvim-dap ([#33](https://github.com/nvim-java/nvim-java-core/issues/33))
* go from promises to co-routines ([#23](https://github.com/nvim-java/nvim-java-core/issues/23))
* improvements in project structure & architecture ([#21](https://github.com/nvim-java/nvim-java-core/issues/21))
* let jdtls wrapper script handle launching the server ([#20](https://github.com/nvim-java/nvim-java-core/issues/20))
* make current project a core module ([#8](https://github.com/nvim-java/nvim-java-core/issues/8))
* rename the module to java core ([#5](https://github.com/nvim-java/nvim-java-core/issues/5))

### Features

* add await_handle_ok handler ([#37](https://github.com/nvim-java/nvim-java-core/issues/37)) ([ccac829](https://github.com/nvim-java/nvim-java-core/commit/ccac8297121929a898478680c65ce64f042b1031))
* add decompile command and enable class file support in jdtls ([#10](https://github.com/nvim-java/nvim-java-core/issues/10)) ([5ef224f](https://github.com/nvim-java/nvim-java-core/commit/5ef224f90766f7f352f3918fc67012161e4b407b))
* add editor config ([00d015a](https://github.com/nvim-java/nvim-java-core/commit/00d015aa432b25b6183192ecbf112123f52b7854))
* add get_test_methods API to get a list of methods in curren class ([#25](https://github.com/nvim-java/nvim-java-core/issues/25)) ([a1c750e](https://github.com/nvim-java/nvim-java-core/commit/a1c750e9fb627375055558b61d04f71813ad72ff))
* add java test run APIs ([#10](https://github.com/nvim-java/nvim-java-core/issues/10)) ([960425f](https://github.com/nvim-java/nvim-java-core/commit/960425fa210b3a53bb555461adc36787cfb521f4))
* add lint & release-please workflows ([#42](https://github.com/nvim-java/nvim-java-core/issues/42)) ([5a4b050](https://github.com/nvim-java/nvim-java-core/commit/5a4b0509df6dca24719141184b8059db114e332e))
* API for generating jdtls config ([#2](https://github.com/nvim-java/nvim-java-core/issues/2)) ([d3bcc87](https://github.com/nvim-java/nvim-java-core/commit/d3bcc87f02695184704503c05c890b48f935c5fa))
* dap config and adapter for java ([#3](https://github.com/nvim-java/nvim-java-core/issues/3)) ([4274221](https://github.com/nvim-java/nvim-java-core/commit/4274221a549be1a8817f243e518a439551c3c77d))
* **doc:** add server capability doc ([45132d7](https://github.com/nvim-java/nvim-java-core/commit/45132d7fe4492e30d68cb3712e7878f86dad2fb2))
* run_test to take config to override the calculated launch config ([#12](https://github.com/nvim-java/nvim-java-core/issues/12)) ([b00bd57](https://github.com/nvim-java/nvim-java-core/commit/b00bd57a54a43ff0006e8a27eee56d1766ae014f))
* test report ([#30](https://github.com/nvim-java/nvim-java-core/issues/30)) ([d3c0dc6](https://github.com/nvim-java/nvim-java-core/commit/d3c0dc6ae934ce34ecc4832d7dfbc62eb1a6b16a))
* update DAP info in readme ([e7e1436](https://github.com/nvim-java/nvim-java-core/commit/e7e14364590ac1261744257f5abb1ac422128fd5))
* use the jdk installed via mason ([#35](https://github.com/nvim-java/nvim-java-core/issues/35)) ([89aaf0e](https://github.com/nvim-java/nvim-java-core/commit/89aaf0e97183022a8a000da663847c8b54de17af))


### Bug Fixes

* $/progress messages are not displayed correctly ([#15](https://github.com/nvim-java/nvim-java-core/issues/15)) ([10fcd5a](https://github.com/nvim-java/nvim-java-core/commit/10fcd5a0800837bfd0755e8778e8e2d774c0248d))
* **ci:** automated doc update fail due to no commit permission ([#2](https://github.com/nvim-java/nvim-java-core/issues/2)) ([5dadc56](https://github.com/nvim-java/nvim-java-core/commit/5dadc561fdbcabfedf186cea5e651e057bd7fa3a))
* **ci:** vimdoc update to create a pull request instead of commit ([dd313a1](https://github.com/nvim-java/nvim-java-core/commit/dd313a19f37a50074c75cb5b5980d3ba81f73d60))
* trying to concat table to create error message in co-routines ([#29](https://github.com/nvim-java/nvim-java-core/issues/29)) ([3e58a60](https://github.com/nvim-java/nvim-java-core/commit/3e58a606f391b4ee995b022a16f900cfbdc2693e))


### Code Refactoring

* go from promises to co-routines ([#23](https://github.com/nvim-java/nvim-java-core/issues/23)) ([fbedce3](https://github.com/nvim-java/nvim-java-core/commit/fbedce374c2a653890ce3c7f9834131aa49b4ce3))
* improvements in project structure & architecture ([#21](https://github.com/nvim-java/nvim-java-core/issues/21)) ([0b0716b](https://github.com/nvim-java/nvim-java-core/commit/0b0716bd85113c6b676b1631d4690a8e9dae6ceb))
* let jdtls wrapper script handle launching the server ([#20](https://github.com/nvim-java/nvim-java-core/issues/20)) ([f7c80ca](https://github.com/nvim-java/nvim-java-core/commit/f7c80caf28d654c4c92e23b30ce57014f2426630))
* make current project a core module ([#8](https://github.com/nvim-java/nvim-java-core/issues/8)) ([fe84fe5](https://github.com/nvim-java/nvim-java-core/commit/fe84fe579ca63e057176367391ba601c4fb0bbf6))
* move dap APIs to nvim-dap ([#33](https://github.com/nvim-java/nvim-java-core/issues/33)) ([b23aa35](https://github.com/nvim-java/nvim-java-core/commit/b23aa35c4bb71c4b7c60c11c09936fe7d7dbc648))
* rename the module to java core ([#5](https://github.com/nvim-java/nvim-java-core/issues/5)) ([c08180b](https://github.com/nvim-java/nvim-java-core/commit/c08180b2d1bf888793939c1f635e43cd2bd9d253))
