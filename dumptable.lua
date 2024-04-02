local type = type
local pairs = pairs
local rawget = rawget
local tostring = tostring
local string_rep = string.rep
local string_gsub = string.gsub
local table_concat = table.concat

--- Dump table to string.
---@param t table @ The table you want to dump
---@param maxLev number @ Maximum level of dump
---@return string
local function dumptable(t, maxLev)
    maxLev = maxLev or 10

    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string_rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string_gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end

        local objTostring = rawget(obj, "tostring")
        if objTostring then
            if type(objTostring) == "function" then
                return objTostring()
            else
                return objTostring
            end
        end

        level = level + 1

        if level >= maxLev then
            return "*MAX LEVEL*"
        end

        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
			tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table_concat(tokens, "\n")
    end
    return dumpObj(t, 0)
end

return dumptable
