(import json
        os
        [webbrowser :as web]
        [requests :as req])

;; API credentials
(setv *client-id* "")
(setv *api-key* "")

;; Freesound urls
(setv *base-url* "https://www.freesound.org/apiv2")
(setv *oauth-url* "/oauth2/authorize/")
(setv *token-url* "/oauth2/access_token/")
(setv *search-url* "/search/text/")
(setv *sound-url* "/sounds/%s/download")

;; Init access token variable
(setv *access-token* None)

(defn freesound-url [endpoint &optional params]
  "Generate a freesound.org api url
   Accepts an optional param dict"
  (setv tail (if-not (none? params)
                     (do
                      (setv tail-url ["?"]
                            eq "="
                            and-sym "&")
                      (lfor
                       key params
                       :setv val (get params key)
                       (.append tail-url (+ (if (> (len tail-url) 1)
                                                and-sym
                                                (str)) key eq val)))
                      (.join (str) tail-url))
                     (str)))
  (+ *base-url* endpoint tail))

(defn get-freesound [url &optional payload auth]
  "GET helper function to compose the request"
  (setv xpayload {"token" *api-key*}
        header None)
  (if-not (none? auth)
          (setv header (with-auth-header)))
  (if (coll? payload)
      (.update xpayload payload))
  (.get req
        (freesound-url url)
        :params xpayload
        :headers header))

(defn post-freesound [url data &optional auth]
  "POST helper function to compose the request"
  (setv header None)
  (if-not (none? auth)
          (setv header (with-auth-header)))
  (.post req
         (freesound-url url)
         :data data
         :headers header))

(defn authorize-freesound []
  (setv url (freesound-url *oauth-url* {"client_id" *client-id*
                                        "response_type" "code"}))
  (print "Authorize in browser and paste code in Stdin.")
  (print url)
  (.open web url :new 2)
  (set-access-token (input)))

(defn set-access-token [code]
  (global *access-token*)
  (setv rq (post-freesound *token-url*
            {"client_id" *client-id*
             "client_secret" *api-key*
             "grant_type" "authorization_code"
             "code" code}))
  (if (= rq.status_code req.codes.ok)
      (as-> (.loads json rq.text) it
            (get it "access_token")
            (setv *access-token* it))
      (.raise_for_status rq)))

(defn with-auth-header []
  (if (none? *access-token*)
      (authorize-freesound))
  (identity {"Authorization" (+ "Bearer " *access-token*)}))

(defn search-sound [search-str &optional filter-req filter-res]
  "Search sound from freesound and return list of dictionaries
   the result can be filtered by passing the optional field filter-res
   if filter-res is just one string the result is a list of that field extracted from the result (if there is some) 
   if filter-res is a list then a new dict is composed
   check https://freesound.org/docs/api/resources_apiv2.html#text-search for possible fields"
  (setv rq (get-freesound *search-url*
                          :payload {"query" search-str
                                    "filter" filter-req}))
  (as-> (.loads json rq.text) it
        (get it "results")
        (if-not (none? filter-res)
            (map (fn [curr]
                   (if (coll? filter-res)
                      (do
                       (setv dict-filtered {})
                       (for [el filter-res]
                         (setv get-el (.get curr el))
                         (if-not (none? get-el)
                           (.update dict-filtered {(keyword el) get-el})))
                       dict-filtered)
                    (.get curr filter-res)))
                 it)
            it)
        (list it)))

(defn download-sound [sound-id &optional path filename]
  "By a given id of a sound is possible to download it
   is possible to specify a custom path and filename"
  (setv filename (if (none? filename) "sound.wav" filename)
        path (if (none? path) "./samples/" path)
        rq (get-freesound
            (% *sound-url* sound-id)
            :auth True))
  (if-not (.exists os.path path)
    (.makedirs os path))
  (.write (open (.format "{path}{filename}" :path path :filename filename) "wb") rq.content))
