# Rhino

Rhino is a simple Ruby server that can run rack apps. It is written as a fun experiment.

## Installation

```bash
gem install rhino
```

## Usage

```bash
rhino
```

## Advanced

```bash
rhino [options] [./config.ru]
    -h, --help     help
    -v, --version  version
    -b, --bind     bind (default: 0.0.0.0)
    -p, --port     port (default: 5000)
    --backlog      backlog (default: 64)
    --reuseaddr    reuseaddr (default: true)
```

## Status

[![CircleCI](https://circleci.com/gh/ksylvest/rhino.svg?style=svg)](https://circleci.com/gh/ksylvest/rhino)
[![CodeClimate (Maintainability)](https://api.codeclimate.com/v1/badges/954685d3791ec3d34b63/maintainability)](https://codeclimate.com/github/ksylvest/rhino/maintainability)
[![CodeClimate (Test Coverage)](https://api.codeclimate.com/v1/badges/954685d3791ec3d34b63/test_coverage)](https://codeclimate.com/github/ksylvest/rhino/test_coverage)

## Copyright

Copyright (c) 2015 - 2018 [Kevin Sylvestre](https://ksylvest.com). See LICENSE for details.
