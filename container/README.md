# Workshop containers

The Docker and Apptainer images contain Quarto, Pixi, and the environment defined by `pixi.toml` and `pixi.lock`. The Pixi environment is activated automatically when a shell starts, and its commands are also available when a command is executed directly.

The images currently target `linux/amd64` because the Pixi lockfile contains only the `linux-64` platform.

## Docker

Pull the versioned image:

```bash
docker pull --platform linux/amd64 ghcr.io/nbisweden/workshop-ngsintro:2.5.1
```

Start a shell with the current directory mounted at `/work`:

```bash
docker run --rm -it \
	--platform linux/amd64 \
	--volume "$PWD:/work" \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1
```

Render the complete website:

```bash
docker run --rm \
	--platform linux/amd64 \
	--volume "$PWD:/work" \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1 \
	quarto render
```

Start a Quarto preview server at <http://localhost:8800>:

```bash
docker run --rm -it \
	--platform linux/amd64 \
	--volume "$PWD:/work" \
	--publish 8800:8800 \
	ghcr.io/nbisweden/workshop-ngsintro:2.5.1 \
	quarto preview --host 0.0.0.0 --port 8800
```

Build the image locally from the repository root, optionally selecting another Quarto version:

```bash
docker build \
	--platform linux/amd64 \
	--build-arg QUARTO_VERSION=1.10.18 \
	--file container/dockerfile \
	--tag workshop-ngsintro:local \
	.
```

## Apptainer

Pull the versioned SIF image from GHCR:

```bash
apptainer pull workshop-ngsintro.sif \
	oras://ghcr.io/nbisweden/workshop-ngsintro-apptainer:2.5.1
```

Start a shell with the current directory mounted at `/work`:

```bash
apptainer shell \
	--bind "$PWD:/work" \
	--pwd /work \
	workshop-ngsintro.sif
```

Render the complete website:

```bash
apptainer exec \
	--bind "$PWD:/work" \
	--pwd /work \
	workshop-ngsintro.sif \
	quarto render
```

Start a Quarto preview server at <http://localhost:8800>:

```bash
apptainer exec \
	--bind "$PWD:/work" \
	--pwd /work \
	workshop-ngsintro.sif \
	quarto preview --host 0.0.0.0 --port 8800
```

Build the SIF image locally from the `container` directory, optionally selecting another Quarto version:

```bash
cd container
apptainer build --fakeroot \
	--build-arg QUARTO_VERSION=1.10.18 \
	workshop-ngsintro.sif apptainer.def
```

Use `sudo apptainer build` instead when unprivileged builds are not enabled on the host.
