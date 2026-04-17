import pya

input_gds = globals().get("input")
output_png = globals().get("output")
layer_props = globals().get("lyp")
width = int(globals().get("width", 1600))
height = int(globals().get("height", 1600))

if not input_gds or not output_png:
    raise RuntimeError(
        "Usage: QT_QPA_PLATFORM=offscreen klayout -z -nc -rx "
        "-rd input=<gds> -rd output=<png> [-rd lyp=<lyp>] "
        "-r scripts/render_gds_preview.py"
    )

app = pya.Application.instance()
mw = app.main_window()
mw.load_layout(input_gds, 0)
view = mw.current_view()

if layer_props:
    view.load_layer_props(layer_props)
else:
    view.add_missing_layers()

view.max_hier()
view.zoom_fit()
view.save_image(output_png, width, height)
