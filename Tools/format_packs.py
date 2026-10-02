"""Formats pack JSON files consistently: fixed key order, short lists on one line.

Usage: python3 Tools/format_packs.py TiffinTales/Resources/Packs/*.json
"""
import json
import sys

PACK_KEYS = ["id", "name", "emoji", "region", "countries", "elderNames", "summary", "isCore", "featured", "foods", "remedies"]
FOOD_KEYS = ["id", "name", "localName", "emoji", "blurb", "nutrients", "tags", "diet", "allergens", "sometimes"]
REMEDY_KEYS = ["id", "name", "localName", "emoji", "treats", "howItHelps", "steps", "caution", "diet", "allergens", "author"]


def ordered(obj, keys, drop_defaults):
    out = {k: obj[k] for k in keys if k in obj}
    out.update({k: v for k, v in obj.items() if k not in out})
    for key, default in drop_defaults.items():
        if key in out and out[key] == default:
            out.pop(key)
    return out


def scalar_list(value):
    return isinstance(value, list) and all(not isinstance(v, (dict, list)) for v in value)


def dump(value, indent=0):
    pad = "  " * indent
    if isinstance(value, dict):
        lines = [f'{pad}  {json.dumps(k)}: {dump(v, indent + 1).lstrip()}' for k, v in value.items()]
        return pad + "{\n" + ",\n".join(lines) + "\n" + pad + "}"
    if isinstance(value, list):
        if scalar_list(value) and len(json.dumps(value, ensure_ascii=False)) < 90:
            return pad + json.dumps(value, ensure_ascii=False, separators=(", ", ": "))
        if scalar_list(value):
            items = [pad + "  " + json.dumps(v, ensure_ascii=False) for v in value]
        else:
            items = [dump(v, indent + 1) for v in value]
        return pad + "[\n" + ",\n".join(items) + "\n" + pad + "]"
    return pad + json.dumps(value, ensure_ascii=False)


def normalize(pack):
    pack = ordered(pack, PACK_KEYS, {"isCore": False, "featured": False, "countries": [], "elderNames": []})
    for key in ("foods", "remedies"):
        if key in pack:
            item_keys = FOOD_KEYS if key == "foods" else REMEDY_KEYS
            pack[key] = [ordered(item, item_keys, {"sometimes": False, "allergens": [], "localName": None, "caution": None})
                         for item in pack[key]]
            for item in pack[key]:
                for list_key in ("allergens", "treats"):
                    if list_key in item:
                        item[list_key] = sorted(item[list_key])
    return pack


for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as f:
        pack = json.load(f)
    with open(path, "w", encoding="utf-8") as f:
        f.write(dump(normalize(pack)) + "\n")
