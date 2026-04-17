DESIGN       = picorv32
RTL_FILELIST = rtl.f
RTL_FILES    := $(shell tr '\n' ' ' < $(RTL_FILELIST))

.PHONY: sim lint clean

sim: lint

lint:
	verilator --lint-only -Wno-fatal \
		--top-module $(DESIGN) \
		$(RTL_FILES)

clean:
	rm -rf build
