SQLITE_VERS=3330000
SQLITE_PKG=sqlite-amalgamation-$(SQLITE_VERS)
SQLITE_ZIP=$(SQLITE_PKG).zip
MAIN_C=$(SQLITE_PKG)/main.c
PATCH_DIR=.
UNZIP=/usr/bin/unzip -u

build: $(SQLITE_PKG)/main.c

install: $(SQLITE_PKG)/main.c
	cp $(SQLITE_PKG)/main.c Sources/fdb/
	cp $(SQLITE_PKG)/sqlite3.h Sources/fdb/
	cp $(SQLITE_PKG)/sqlite3ext.h Sources/fdb/
	
$(SQLITE_PKG): $(SQLITE_ZIP)
	$(UNZIP)  $(SQLITE_ZIP)

$(SQLITE_ZIP):
	curl -O https://sqlite.org/2020/$(SQLITE_ZIP)
	
patch: $(MAIN_C)

$(MAIN_C): $(SQLITE_PKG)
	$(MAKE) -f ../Makefile -C  $(SQLITE_PKG) main.c

# This make rule is crafted to be executed w/in the sqlite pkg
main.c:
	cp shell.c main.c
	# Patch 1
	csplit -k main.c /"static int enableTimer = 0"/-2
	cat xx00 > main.c
	@echo "#ifdef FEISTY_DB_EXTENSION" >> main.c
	@echo "extern void feisty_init(void* db);" >> main.c
	@echo "extern int feisty_shell_cmd(char **, int);" >> main.c
	@echo "#endif" >> main.c
	cat xx01 >> main.c
	# Patch 2
	split -p 'sqlite3_fileio_init.*p->db' main.c part_
	cat part_aa > main.c
	@echo "#ifdef FEISTY_DB_EXTENSION" >> main.c
	@echo "      feisty_init(p->db);" >> main.c
	@echo "#endif" >> main.c
	cat part_ab >> main.c
	# Patch 3
	csplit -k main.c /"Error: unknown command or invalid arguments: "/-2
	cat xx00 > main.c
	@echo "#ifdef FEISTY_DB_EXTENSION" >> main.c
	@echo "  if(feisty_shell_cmd(azArg, nArg)){" >> main.c
	@echo "  }else" >> main.c
	@echo "#endif" >> main.c
	cat xx01 >> main.c
	# Clean up
	rm part_* xx*


