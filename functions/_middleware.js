// Demo only: simulate a regional outage on the Cloudflare Pages preview.
// Requests from South Korea get a 503; everything else is served normally.
// Only the Seoul SM probe should see the failure.
export async function onRequest({ request, next }) {
  if (request.cf?.country === "KR") {
    return new Response("Unavailable in this region", { status: 503 });
  }
  return next();
}
