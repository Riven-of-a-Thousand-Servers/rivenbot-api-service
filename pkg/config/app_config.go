package config

import (
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/go-yaml/yaml"
)

type AppConfig struct {
	Datasource DataSource `yaml:"datasource"`
}

type DataSource struct {
	Database string `yaml:"database"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Host     string `yaml:"host"`
	Port     string `yaml:"port"`
}

func ParseConfig(location string) (AppConfig, error) {
	bytes, err := os.ReadFile(location)
	if err != nil {
		return AppConfig{}, err
	}

	var appconfig AppConfig
	yaml.Unmarshal(bytes, &appconfig)

	if err := resolveDockerSecrets(&appconfig); err != nil {
		return AppConfig{}, err
	}

	if err := validateFields(appconfig); err != nil {
		return AppConfig{}, err
	}

	return appconfig, err
}

func resolveDockerSecrets(config *AppConfig) error {
	secretify := func(val string) (string, error) {
		val = os.ExpandEnv(val)
		if strings.HasPrefix(val, "/run/secrets/") {
			data, err := os.ReadFile(val)
			if err != nil {
				return "", fmt.Errorf("Failed to read secret file %s: %v", val, err)
			}
			return strings.TrimSpace(string(data)), nil
		}
		return val, nil
	}

	var err error
	config.Datasource.Username, err = secretify(config.Datasource.Username)
	if err != nil {
		return err
	}

	config.Datasource.Password, err = secretify(config.Datasource.Password)
	if err != nil {
		return err
	}

	config.Datasource.Database, err = secretify(config.Datasource.Database)
	if err != nil {
		return err
	}

	config.Datasource.Port, err = secretify(config.Datasource.Port)
	if err != nil {
		return err
	}

	config.Datasource.Host, err = secretify(config.Datasource.Host)
	if err != nil {
		return err
	}

	return nil
}

func validateFields(appconfig AppConfig) error {
	switch {
	case appconfig.Datasource.Database == "":
		return errors.New("No database found")
	case appconfig.Datasource.Username == "":
		return errors.New("No default username found")
	case appconfig.Datasource.Password == "":
		return errors.New("No password was found")
	case appconfig.Datasource.Host == "":
		return errors.New("No host was found")
	case appconfig.Datasource.Port == "":
		return errors.New("No port was found")
	}
	return nil
}
