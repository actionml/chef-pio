
[![Travis](https://img.shields.io/travis/actionml/chef-pio.svg)](https://travis-ci.org/actionml/chef-pio)

# PredictionIO chef cookbook

PredictionIO is an open source Machine Learning Server built on top of state-of-the-art open source stack for developers and data scientists create predictive engines for any machine learning task. PredictionIO cookbook aims to provide two variants of installation  **standalone** and **all-in-one** (**AIO**).

The standalone variant installs and configures a system to run PIO EventServer/PredictionServer or a PIO driver machines. This installs the PIO stack sources (Hadoop/HBase/Spark), builds PIO and writes its configuration files.

The second variant is **AIO** installs and sets the system up with all the required services on a single machine. Apache dependencies such as Hadoop/HBase/Spark are configured in *Pseudo Distributed* mode. It's strongly suggested to the end-user to use this variant to evaluate PredictionIO.

## Current software versions

* PredictionIO - 0.12.1
* Universal Recommender - 0.7.0
* Mahout - 0.13.0
* OpenJDK8
* Hadoop - 2.8.3
* HBase - 1.4.3
* Spark - 2.1.2

## Supported Platforms

We support: 
 - Debian *>= 8*
 - Ubuntu *>= 14.04*
 - CentOS *>= 7*

Actually any systemd/upstart based system should work smooth, though there are cookbook metadata restrictions for the given platforms. Feel free to change this, please open a PR and contribute.

## Cookbook attributes

This cookbooks contains quite a long list of attributes, we won't try to cover all of them here rather than just try to introduce the most important ones to you. For the complete list see [attributes/](attributes/).

| Attribute | Description | Default value |
|---|---|---|
| **pio.user** | User used for operating PredictionIO. | `'aml'` |
| **pio.home** | PIO user's home directory. Specify to change the default (`/opt/data/aml-home` which is symlinked to `/home/aml`).  | `''` |
| **pio.localdir** | Directory containing all the installed applications and services. | `'/usr/local'` |
| **pio.datadir** | Directory used as the top data store for all the installed services. | `'/opt/data'` |
| **pio.git\*** | Attributes setting the pio Git source location and version. |
| **pio.mahout.git\*** | Attributes setting the Mahout Git source location and version. |
| **pio.ur.git\*** | Attributes setting the Universal Recommender Git source location and version. |
| **pio.conf.event_server** | Specifies the PredictionIO Event Server port. | `7070` |
| **pio.conf.prediction_server** | Specifies the PredictionIO Prediction Server port. | `8000` |
| **pio.hdfs_structure** | Specifies initial HDFS layout to bootstrap. | *see attributes* |

## Usage

### pio::default

For the **standalone** installation, include `pio` recipe in your node's `run_list`.

### pio::aio

For the **AIO** installation, include `pio::aio` recipe in your node's `run_list`.


## License and Authors

 - Author:: ActionML (<devops@actionml.com>)
 - Author:: Denis Baryshev (<dennybaa@gmail.com>)
