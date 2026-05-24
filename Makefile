# skill-hub — standalone skill installer
#
# Install individual skills or curated bundles into one or more IDEs.
#
# Usage:
#   make <skill-or-bundle> [IDE="<ide1> <ide2> ..."]
#
# Supported IDEs (space-separated list, default: claude):
#   claude, cursor, codex, copilot
#
# Examples:
#   make lets-develop-feature                          # install one skill to claude
#   make lets-develop-feature IDE=cursor               # install one skill to cursor
#   make lets-develop-feature IDE="claude cursor"      # install one skill to both
#   make engineering                                   # install the engineering bundle
#   make engineering pm IDE="claude codex"             # two bundles, two IDEs
#   make all IDE="claude cursor codex copilot"         # everything, everywhere

# --------------------------------------------------------------------------- #
# IDE selection                                                               #
# --------------------------------------------------------------------------- #

IDE := $(strip $(IDE))
ifeq ($(IDE),)
  IDE := claude
endif

# Per-IDE install paths. Override individually, or set LETS_SKILLS_DIR to
# force every IDE to install into the same directory.
CLAUDE_SKILLS_DIR  ?= $(HOME)/.claude/skills
CURSOR_SKILLS_DIR  ?= $(HOME)/.cursor/skills
CODEX_SKILLS_DIR   ?= $(HOME)/.codex/skills
COPILOT_SKILLS_DIR ?= $(HOME)/.github/skills

# Validate every IDE value at parse time — fail fast on typos.
$(foreach p,$(IDE),$(if $(filter claude cursor codex copilot,$(p)),,\
  $(error Unsupported IDE="$(p)". Valid: claude, cursor, codex, copilot)))

REPO_DIR := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)

# --------------------------------------------------------------------------- #
# Install function — copies a skill into every IDE in $(IDE)                  #
# --------------------------------------------------------------------------- #

define install_skill
	@set -e; \
	for ide in $(IDE); do \
	  case "$$ide" in \
	    claude)  target_dir="$(CLAUDE_SKILLS_DIR)" ;; \
	    cursor)  target_dir="$(CURSOR_SKILLS_DIR)" ;; \
	    codex)   target_dir="$(CODEX_SKILLS_DIR)" ;; \
	    copilot) target_dir="$(COPILOT_SKILLS_DIR)" ;; \
	  esac; \
	  if [ -n "$(LETS_SKILLS_DIR)" ]; then target_dir="$(LETS_SKILLS_DIR)"; fi; \
	  mkdir -p "$$target_dir/$(1)"; \
	  cp -R "$(REPO_DIR)/$(1)/." "$$target_dir/$(1)/"; \
	  echo "  ✓ $(1) → $$ide ($$target_dir/$(1))"; \
	done
endef

# --------------------------------------------------------------------------- #
# Bundle definitions — single source of truth                                 #
# Editing a bundle here updates both the targets below and `make all`.        #
# --------------------------------------------------------------------------- #

STARTER_SKILLS := \
  lets-start-here \
  lets-onboard-repo \
  lets-bootstrap-repo \
  lets-bootstrap-agents-md

ENGINEERING_SKILLS := \
  lets-create-plan \
  lets-develop-feature \
  lets-verify-change \
  lets-verify-ready \
  lets-review-code \
  lets-review-pr \
  lets-spec-to-pr

PM_SKILLS := \
  lets-brainstorm \
  lets-opportunity-discovery \
  lets-research-prd-grooming

DESIGN_SKILLS := \
  lets-research-ux-walkthrough \
  lets-research-content-evaluate

RESEARCH_SKILLS := \
  lets-research-competitive-scan \
  lets-research-content-evaluate \
  lets-research-ux-walkthrough \
  lets-research-prd-grooming \
  lets-opportunity-discovery

READINESS_SKILLS := \
  lets-assess-ai-readiness \
  lets-bootstrap-agents-md \
  lets-bootstrap-repo

# Union of every bundle — used by `make all`.
# sort/uniques skills that appear in more than one bundle.
ALL_SKILLS := $(sort \
  $(STARTER_SKILLS) \
  $(ENGINEERING_SKILLS) \
  $(PM_SKILLS) \
  $(DESIGN_SKILLS) \
  $(RESEARCH_SKILLS) \
  $(READINESS_SKILLS))

# --------------------------------------------------------------------------- #
# Phony declarations                                                          #
# --------------------------------------------------------------------------- #

.PHONY: all help \
        starter engineering pm design research readiness \
        $(ALL_SKILLS)

# --------------------------------------------------------------------------- #
# Default target — show help                                                  #
# --------------------------------------------------------------------------- #

help:
	@echo "skill-hub — install skills into one or more IDEs"
	@echo ""
	@echo "Bundles (curated groups):"
	@echo "  make starter        — first-time setup (onboard + bootstrap)"
	@echo "  make engineering    — code delivery: plan → build → verify → review"
	@echo "  make pm             — product management: brainstorm, opportunities, PRDs"
	@echo "  make design         — UX walkthrough, content evaluation"
	@echo "  make research       — competitive scan, content eval, UX, PRD grooming"
	@echo "  make readiness      — assess + bootstrap a repo for AI readiness"
	@echo "  make all            — every skill in the repo"
	@echo ""
	@echo "Individual skills (18 total):"
	@for s in $(ALL_SKILLS); do echo "  make $$s"; done
	@echo ""
	@echo "IDEs: claude (default), cursor, codex, copilot"
	@echo ""
	@echo "Examples:"
	@echo "  make engineering IDE=cursor"
	@echo "  make lets-develop-feature IDE=\"claude cursor\""
	@echo "  make engineering pm IDE=\"claude codex\""

# --------------------------------------------------------------------------- #
# Individual skill targets                                                    #
# --------------------------------------------------------------------------- #

lets-assess-ai-readiness:
	$(call install_skill,lets-assess-ai-readiness)

lets-bootstrap-agents-md:
	$(call install_skill,lets-bootstrap-agents-md)

lets-bootstrap-repo:
	$(call install_skill,lets-bootstrap-repo)

lets-brainstorm:
	$(call install_skill,lets-brainstorm)

lets-create-plan:
	$(call install_skill,lets-create-plan)

lets-develop-feature:
	$(call install_skill,lets-develop-feature)

lets-onboard-repo:
	$(call install_skill,lets-onboard-repo)

lets-opportunity-discovery:
	$(call install_skill,lets-opportunity-discovery)

lets-research-competitive-scan:
	$(call install_skill,lets-research-competitive-scan)

lets-research-content-evaluate:
	$(call install_skill,lets-research-content-evaluate)

lets-research-prd-grooming:
	$(call install_skill,lets-research-prd-grooming)

lets-research-ux-walkthrough:
	$(call install_skill,lets-research-ux-walkthrough)

lets-review-code:
	$(call install_skill,lets-review-code)

lets-review-pr:
	$(call install_skill,lets-review-pr)

lets-spec-to-pr:
	$(call install_skill,lets-spec-to-pr)

lets-start-here:
	$(call install_skill,lets-start-here)

lets-verify-change:
	$(call install_skill,lets-verify-change)

lets-verify-ready:
	$(call install_skill,lets-verify-ready)

# --------------------------------------------------------------------------- #
# Bundle targets — depend on individual skill targets                         #
# --------------------------------------------------------------------------- #

starter:     $(STARTER_SKILLS)
	@echo "→ starter bundle installed ($(words $(STARTER_SKILLS)) skills)"

engineering: $(ENGINEERING_SKILLS)
	@echo "→ engineering bundle installed ($(words $(ENGINEERING_SKILLS)) skills)"

pm:          $(PM_SKILLS)
	@echo "→ pm bundle installed ($(words $(PM_SKILLS)) skills)"

design:      $(DESIGN_SKILLS)
	@echo "→ design bundle installed ($(words $(DESIGN_SKILLS)) skills)"

research:    $(RESEARCH_SKILLS)
	@echo "→ research bundle installed ($(words $(RESEARCH_SKILLS)) skills)"

readiness:   $(READINESS_SKILLS)
	@echo "→ readiness bundle installed ($(words $(READINESS_SKILLS)) skills)"

all: $(ALL_SKILLS)
	@echo "→ all skills installed ($(words $(ALL_SKILLS)) skills)"
