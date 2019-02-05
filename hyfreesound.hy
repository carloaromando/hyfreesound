(import [requests :as req]
        json)

;; API credentials
(setv *client-id* "fRxIldu3tCZb4WjdPhZI")
(setv *api-key* "zX3zHJJy0ukDqKPIPNNKXr2ynmksbkEqyWW80d6W")

;; Freesound urls
(setv *base-url* "https://www.freesound.org/apiv2")
(setv *search-url* "/search/text")
(setv *sound-url* "/sounds/%s")

;; GET helper
(defn get-freesound [url &optional payload]
  (setv xpayload {"token" *api-key*})
  (if (!= None payload)
      (.update xpayload payload))
  (.get req
        (+ *base-url* url)
        :params xpayload))

;; Search sound GET
(defn search-sound [search-str]
  (setv r (get-freesound
            *search-url*
            :payload {"query" search-str}))
  (list (map
          (fn [it] (.get it "id"))
          (-> (.loads json r.text)
              (.get "results")))))

;; Download sound by id and stores it in a new dir "samples" at root
(defn download-sound [sound-id]
  (setv r (get-freesound
            (% *sound-url* sound-id)))
  (print (.json r)))
