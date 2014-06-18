#!/bin/sh

erl -pa ebin -eval 'bertrpc_server:start(9999,[lists]).'
