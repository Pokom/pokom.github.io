dev:
	hugo server --navigateToChanged -D

post:
	hugo new posts/$(name).md