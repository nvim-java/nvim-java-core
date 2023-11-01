import re
import urllib.request

things_to_export = []

def _iface(text):
    lines = text.split('\n')
    lua_lines = []

    for line in lines:
        line = line.strip()
        if line.startswith("interface"):
            interface_name = line.split(" ")[1]
            lua_lines.append(f'---@class {interface_name}')
        elif line.startswith("{") or line.startswith("}"):
            continue
        elif line.startswith("/") or line.startswith("*"):
            continue
        elif line:
            properties = re.findall('\s*(\w*\?*):(\?*) *(\w*)', line)
            lua_lines.append(f'---@field {properties[0][0]} {properties[0][2]}')

    lua_lines.append('\n')
    lua_annotation = "\n".join(lua_lines)

    return lua_annotation

def _enum(text):
    lines = text.split('\n')
    lua_lines = []

    for line in lines:
        line = line.strip()
        if line.startswith("enum"):
            interface_name = line.split(" ")[1]
            lua_lines.append(f'---@enum {interface_name}')
            lua_lines.append(f'M.{interface_name} = {{')
            things_to_export.append(interface_name)
        elif line.startswith("{") or line.startswith("}"):
            continue
        elif line.startswith("/") or line.startswith("*"):
            continue
        elif line:
            suffix = ''
            if line.endswith(',') != True:
                suffix = ','
            lua_lines.append('\t' + line + suffix)

    lua_lines.append('}')
    lua_lines.append('\n')
    lua_annotation = "\n".join(lua_lines)

    return lua_annotation

lua_doc = ''

lua_doc = lua_doc + 'local M = {}\n'

content = urllib.request.urlopen("https://raw.githubusercontent.com/wiki/eclipse-jdtls/eclipse.jdt.ls/Running-the-JAVA-LS-server-from-the-command-line.md").read().decode('utf-8')

code_block_pattern = r'```typescript[a-zA-Z]*\n(.*?)```'
code_blocks = re.findall(code_block_pattern, content, re.DOTALL)


for code_block in code_blocks:
    text = code_block.strip()
    if re.match('^interface', text):
        lua_doc = lua_doc + _iface(text)
    elif re.match('^enum', text):
        lua_doc = lua_doc + _enum(text)

lua_doc = lua_doc + 'return M\n'

with open("./lua/java/jdtls-types.lua", "w") as f:
    f.write(lua_doc)
