.PHONY: start
start:
	elm-live src/Main.elm --open --hot -- --output=built/elm.js --debug & \
	node_modules/.bin/json-server --watch db.json && fg

