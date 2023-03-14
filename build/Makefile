# Get only the list of files that will be used to generate the Workbook
TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: terraform-plan
terraform-plan: ## Execute terraform plan
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))

.PHONY: clean
clean: ## Remove generated files
	rm -f tfplan
	rm -f artifacts/*.workbook
