(import [requests :as req]
        json)

;; API credentials
(setv *client-id* "fRxIldu3tCZb4WjdPhZI")
(setv *api-key* "zX3zHJJy0ukDqKPIPNNKXr2ynmksbkEqyWW80d6W")

;; Freesound urls
(setv *base-url* "https://www.freesound.org/apiv2")
(setv *search-url* "/search/text")
(setv *sound-url* "/sounds/%s")

(defn get-freesound [url &optional payload]
  "GET helper function to compose the request"
  (setv xpayload {"token" *api-key*})
  (if (coll? payload)
      (.update xpayload payload))
  (.get req
        (+ *base-url* url)
        :params xpayload))

(defn search-sound [search-str &optional filter-res]
  "Search sound from freesound and return list of dictionaries
   the result can be filtered by passing the optiona field filter-res
   if filter-res is just one string the result is a list of that field extracted from the result (if there is some) 
  if filter-res is a list then a new dict is composed"
  (setv r (get-freesound *search-url*
            :payload {"query" search-str}))
  (as-> (.loads json r.text) it
        (.get it "results")
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

(defn download-sound [sound-id]
  (setv r (get-freesound
            (% *sound-url* sound-id)))
  (print (.json r)))
