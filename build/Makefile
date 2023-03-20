# Get only the list of files that will be used to generate the Workbook
TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: all
all: build-workbook build-bicep ## Execute all steps

.PHONY: build-workbook
build-workbook: ## Execute terraform plan
	mkdir -p artifacts
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))
	terraform apply -no-color tfplan
	(cd artifacts && ls *.workbook > workbook_filelist)

.PHONY: build-bicep
build-bicep: ## Build Bicep files
	mkdir -p artifacts
	az bicep build -f main.bicep --stdout > azuredeploy.json
	mv azuredeploy.json artifacts

.PHONY: clean
clean: ## Remove generated files
	rm -f tfplan
	rm -rf ./artifacts/