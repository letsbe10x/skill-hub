# skill-hub — standalone skill installer
# Supported platforms: claude-code (default), cursor, codex, copilot
PLATFORM ?= claude-code

CLAUDE_CODE_SKILLS_DIR ?= $(HOME)/.claude/skills
CURSOR_SKILLS_DIR      ?= $(HOME)/.cursor/skills
CODEX_SKILLS_DIR       ?= $(HOME)/.codex/skills
COPILOT_SKILLS_DIR     ?= $(HOME)/.github/skills

ifeq ($(PLATFORM),claude-code)
  SKILLS_DIR := $(CLAUDE_CODE_SKILLS_DIR)
else ifeq ($(PLATFORM),cursor)
  SKILLS_DIR := $(CURSOR_SKILLS_DIR)
else ifeq ($(PLATFORM),codex)
  SKILLS_DIR := $(CODEX_SKILLS_DIR)
else ifeq ($(PLATFORM),copilot)
  SKILLS_DIR := $(COPILOT_SKILLS_DIR)
else
  $(error Unsupported PLATFORM="$(PLATFORM)". Valid: claude-code, cursor, codex, copilot)
endif

REPO_DIR := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)

define install_skill
	mkdir -p "$(SKILLS_DIR)/$(1)"
	cp -r "$(REPO_DIR)/$(1)/." "$(SKILLS_DIR)/$(1)/"
	@echo "installed: $(1) → $(SKILLS_DIR)/$(1)"
endef

.PHONY: all sdlc research meta \
  lets-start-here lets-bootstrap-agents-md lets-bootstrap-repo lets-develop-feature \
  lets-review-code lets-review-pr lets-verify-change lets-verify-ready \
  lets-spec-to-pr lets-create-plan lets-brainstorm lets-onboard-repo \
  lets-research-content-evaluate lets-research-competitive-scan \
  lets-research-ux-walkthrough lets-research-prd-grooming lets-opportunity-discovery \
  lets-audit-repo lets-author-skill

lets-start-here:            $(call install_skill,lets-start-here)
lets-bootstrap-agents-md:   $(call install_skill,lets-bootstrap-agents-md)
lets-bootstrap-repo:        $(call install_skill,lets-bootstrap-repo)
lets-develop-feature:       $(call install_skill,lets-develop-feature)
lets-review-code:           $(call install_skill,lets-review-code)
lets-review-pr:             $(call install_skill,lets-review-pr)
lets-verify-change:         $(call install_skill,lets-verify-change)
lets-verify-ready:          $(call install_skill,lets-verify-ready)
lets-spec-to-pr:            $(call install_skill,lets-spec-to-pr)
lets-create-plan:           $(call install_skill,lets-create-plan)
lets-brainstorm:            $(call install_skill,lets-brainstorm)
lets-onboard-repo:          $(call install_skill,lets-onboard-repo)
lets-research-content-evaluate:   $(call install_skill,lets-research-content-evaluate)
lets-research-competitive-scan:   $(call install_skill,lets-research-competitive-scan)
lets-research-ux-walkthrough:     $(call install_skill,lets-research-ux-walkthrough)
lets-research-prd-grooming:       $(call install_skill,lets-research-prd-grooming)
lets-opportunity-discovery:       $(call install_skill,lets-opportunity-discovery)
lets-audit-repo:            $(call install_skill,lets-audit-repo)
lets-author-skill:          $(call install_skill,lets-author-skill)

sdlc: lets-start-here lets-bootstrap-agents-md lets-bootstrap-repo lets-develop-feature \
      lets-review-code lets-review-pr lets-verify-change lets-verify-ready \
      lets-spec-to-pr lets-create-plan lets-brainstorm lets-onboard-repo

research: lets-research-content-evaluate lets-research-competitive-scan \
          lets-research-ux-walkthrough lets-research-prd-grooming lets-opportunity-discovery

meta: lets-audit-repo lets-author-skill

all: sdlc research meta
