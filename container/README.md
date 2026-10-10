# Workshop containers

The Docker image contains Quarto, Pixi, and the environment defined by `pixi.toml` and `pixi.lock`. The Pixi environment is activated automatically when a shell starts, and its commands are also available when a command is executed directly.

The image supports `linux/amd64` and `linux/arm64`. Docker automatically selects the native image for Intel/AMD or Apple Silicon hosts.

## Docker

Pull the versioned image:

```bash
docker pull ghcr.io/nbisweden/workshop-ngsintro:2.5.1
```

Start a shell with the current directory mounted at `/work`:

```bash
docker run --rm -it \
	--volume "$PWD:/work" \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1
```

Render the complete website:

```bash
docker run --rm \
	--volume "$PWD:/work" \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1 \
	quarto render
```

Start a Quarto preview server at <http://localhost:8800>:

```bash
docker run --rm -it \
	--volume "$PWD:/work" \
	--publish 8800:8800 \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1 \
	quarto preview --host 0.0.0.0 --port 8800
```

Build the image locally from the repository root, optionally selecting another Quarto version:

```bash
docker build \
	--build-arg QUARTO_VERSION=1.10.18 \
	--file container/dockerfile \
	--tag workshop-ngsintro:local \
	.
```

## Apptainer

Convert the versioned Docker image from GHCR to a local SIF image.

```bash
apptainer build workshop-ngsintro.sif \
	docker://ghcr.io/nbisweden/workshop-ngsintro:2.5.1
```

Run an interactive shell with the current directory mounted at `/work`:

```bash
apptainer shell \
	--bind "$PWD:/work" \
	--pwd /work \
	workshop-ngsintro.sif
```

Alternatively, run a command directly, for example:

```bash
apptainer exec \
	--bind "$PWD:/work" \
	--pwd /work \
	workshop-ngsintro.sif \
	quarto render
```

## GitHub Codespaces

The repository includes a dev container (`.devcontainer/`) built from `container/dockerfile`, so all tools from `pixi.toml` are available in the Codespace terminal. On first creation, `.devcontainer/setup-data.sh` downloads the workshop data from OSF to `data/workshop-data.zip` and unzips it into `data/`. This folder lives in the persistent workspace volume and is git-ignored, so it survives Codespace restarts and is only downloaded once. To fetch it again, delete `data/.extracted` and run `bash .devcontainer/setup-data.sh`.
