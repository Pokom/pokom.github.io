HUGO_IMAGE := hugomods/hugo:0.165.0
DOCKER_RUN := docker run --rm -it -v "$(CURDIR):/src" -w /src

dev:
	$(DOCKER_RUN) -p 1313:1313 $(HUGO_IMAGE) hugo server --navigateToChanged -D --bind 0.0.0.0 --poll 700ms

post:
	$(DOCKER_RUN) $(HUGO_IMAGE) hugo new posts/$(name).md
