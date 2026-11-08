# bypassAIGC 多架构镜像实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 `ghcr.io/socialyjj/bypassaigc:latest` 同时解析到现有 `linux/amd64` 与新增 `linux/arm64` 镜像。

**Architecture:** GitHub Actions 使用 amd64、arm64 原生 runner 分别构建并按 digest 推送；合并任务收集 digest，生成并推送同一组 OCI manifest 标签。PR 只构建验证，不推送镜像。

**Tech Stack:** GitHub Actions、Docker Buildx、GHCR、Actions artifact。

**Spec:** 远端 `master` 上现有 `.github/workflows/build-docker.yml`。

## Global Constraints

- 保留现有 push、tag、pull request 触发条件和镜像标签语义。
- `latest` 必须同时保留 amd64 并新增 arm64，不能用单架构推送覆盖原标签。
- 仅由 GitHub Actions 的 `GITHUB_TOKEN` 推送到 GHCR；pull request 不写入镜像仓库。
- 基于远端 `master` 修改，不带入 `G:\bypassAIGC` 工作区已有的删除改动。

---

### Task 1：建立多架构发布工作流

**Files:**
- Modify: `.github/workflows/build-docker.yml`
- Create: `docs/superpowers/plans/2026-11-08-bypassaigc-arm64-multiarch.md`

**Interfaces:**
- 输入：工作流事件、项目 Dockerfile 和 GHCR 权限。
- 输出：非 PR 事件的镜像 digest artifacts，以及合并后的 `latest`/版本标签。

- [x] **Step 1：替换单平台 build job 为原生 runner 矩阵**

矩阵包含 `linux/amd64` / `ubuntu-24.04` 与 `linux/arm64` / `ubuntu-24.04-arm`。PR 使用 `load: true` 做本地架构构建；push/tag 事件使用 `outputs: type=image,name=...,push-by-digest=true,name-canonical=true,push=true`。

- [x] **Step 2：加入 digest artifact 合并任务**

每个构建任务把 `${DIGEST#sha256:}` 作为 artifact 文件名上传；合并任务下载所有 digest，并执行：

```bash
docker buildx imagetools create \
  $(jq -cr '.tags | map("-t " + .) | join(" ")' <<< "$DOCKER_METADATA_OUTPUT_JSON") \
  $(printf '${IMAGE_NAME}@sha256:%s ' *)
```

- [x] **Step 3：检查工作流与仓库差异**

运行 YAML/Actions 静态检查，确认 PR 不推送，且现有分支、版本和 `latest` 标签规则未改变。只暂存工作流与本计划文件。

- [ ] **Step 4：推送到默认分支并验证发布**

推送后检查对应 Actions run 成功，并检查 `docker buildx imagetools inspect ghcr.io/socialyjj/bypassaigc:latest` 输出同时含 `linux/amd64` 与 `linux/arm64`。
