+++
date = '2025-10-17T23:19:29-04:00'
draft = true
title = 'Slog benchmarks'
+++

I saw a comment on a recent PR that pointed out that Go's `slog.With` caused extra memory allocations because it returns a copy of its logger.
This wasn't the first time I heard this, but it didn't sink what the implications were.


