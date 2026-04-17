DESIGN     = alu
SRC_DIR    = src
TB_DIR     = tb
BUILD_DIR  = build
RTL_FILELIST = rtl.f
RTL_FILES  := $(shell tr '\n' ' ' < $(RTL_FILELIST))

.PHONY: sim clean

sim: $(BUILD_DIR)/V$(DESIGN)
	./$(BUILD_DIR)/V$(DESIGN)

$(BUILD_DIR)/V$(DESIGN): $(RTL_FILELIST) $(TB_DIR)/tb_$(DESIGN).cpp
	mkdir -p $(BUILD_DIR)
	verilator --cc --exe --build -Wno-fatal \
		-Mdir $(BUILD_DIR) \
		--top-module $(DESIGN) \
		$(RTL_FILES) \
		$(TB_DIR)/tb_$(DESIGN).cpp

clean:
	rm -rf $(BUILD_DIR)
