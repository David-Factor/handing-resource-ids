.PHONY: start
start: node_modules elm.json
	node_modules/.bin/elm-live src/Main.elm --open --hot -- --output=built/elm.js --debug & \
	node_modules/.bin/json-server --watch db.json && fg

node_modules: package.json
	npm install

