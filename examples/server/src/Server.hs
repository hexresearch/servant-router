{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

import Data.Proxy
import Network.Wai.Handler.Warp
import Servant
import Servant.HTML.Blaze
import Servant.Router
import Text.Blaze.Html5 as H hiding (main)
import Text.Blaze.Html5.Attributes
import System.Environment

type Views = "books" :> Capture "id" Int :> View
        :<|> "search" :> QueryParam "query" String :> View
views :: Proxy Views
views = Proxy

type Api = "api" :> "books" :> Get '[JSON] [String]
      :<|> Raw
api :: Proxy Api
api = Proxy

type WholeServer = ViewTransform Views (Get '[HTML] Html)
              :<|> Api
wholeServer :: Proxy WholeServer
wholeServer = Proxy

server :: FilePath -> Server WholeServer
server appDir = viewServer :<|> apiServer :<|> serveDirectoryFileServer appDir
 where
  apiServer  = return ["Book Title!"]
  viewServer = constHandler views (Proxy :: Proxy Handler) $ docTypeHtml $ do
    H.head $ do
      script ! src "/all.js" $ return ()
      return ()
    body $ script ! src "/runmain.js" $ return ()

main :: IO ()
main = do
  (appDir:_) <- getArgs
  run 8080 $ serve wholeServer (server appDir)
