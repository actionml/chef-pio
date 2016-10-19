# PredictionIO chef cookbook

PredictionIO is an open source Machine Learning Server built on top of state-of-the-art open source stack for developers and data scientists create predictive engines for any machine learning task.

The main approach is too keep this cookbook simple, so the use case for this cookbook is to bring up either **standalone** PIO or **all-in-one** PIO. The first is aimed to bring up only PIO Event and Prediction Server as well as a PIO driver machine. The second one is used to bring up ALL-in-One PIO machine with the required services such as Hadoop, HBase, ElasticSearch and Spark. Finally this cookbook will never implement any dynamic features, it will remain statically configured via its attributes.

## Supported Platforms

We support: 

 - Ubuntu *>= 14.04*
 - CentOS *>= 7*

If you want this cookbook to work on other platforms you are welcome to open PR and contribute.

## Usage

### pio::default

Include `pio` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[pio::default]"
  ]
}
```

## License and Authors

 - Author:: ActionML (<devops@actionml.com>)
 - Author:: Denis Baryshev (<dennybaa@gmail.com>)
