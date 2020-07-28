#include "http_notify.h"
#include <curl/curl.h>
#include "ejudge/xalloc.h"
int
http_notify(int contest_id, int run_id, int new_status, const char *notification_url)
{

  if (!notification_url || !*notification_url) {
    return -1;
  }

  CURL *curl = curl_easy_init();
  if (!curl) {
    return -1;
  }

  if (new_status >= 90) {
    return 0;
  }

  char *url_s = NULL;
  size_t url_z = 0;
  FILE *url_f = open_memstream(&url_s, &url_z);
  fprintf(url_f, "%s?contest_id=%d&run_id=%d&new_status=%d", notification_url, contest_id, run_id, new_status);
  fclose(url_f);

  curl_easy_setopt(curl, CURLOPT_AUTOREFERER, 1);
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
  curl_easy_setopt(curl, CURLOPT_URL, url_s);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
  CURLcode res = curl_easy_perform(curl);
  xfree(url_s);
  if (res != CURLE_OK) {
    return -1;
  }
  if (curl) {
    curl_easy_cleanup(curl);
  }
  return 0;
}
