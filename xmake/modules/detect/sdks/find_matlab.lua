--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      jacklin
-- @file        find_matlab.lua
--

-- find matlab sdk toolchains
--
-- @return          the matlab sdk toolchains. e.g. {sdkdir = ..., includedirs = ..., linkdirs = ..., .. }
--
-- @code
--
-- local toolchains = find_matlab()
--
-- @endcode
--
function main()
    local result = {sdkdir = "", includedirs = {}, linkdirs = {}, links = {}}
    if is_host("windows") then
        local matlabkey = "HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB" 
        local valuekeys = winos.registry_keys(matlabkey)
        if #valuekeys == 0 then
            return nil
        end
        local itemkey = valuekeys[1] .. ";MATLABROOT"
        local sdkdir = try {function () return winos.registry_query(itemkey) end}
        if not sdkdir then
            return nil
        end
        result.sdkdir = sdkdir
        result.includedirs = path.join(sdkdir, "extern", "include")
        -- find lib dirs
        for _, value in ipairs(os.dirs(path.join(sdkdir, "extern", "lib", "**"))) do
            local dirbasename = path.basename(value)
            if not dirbasename:startswith("win") then
                result.linkdirs[dirbasename] = value
            end
        end
        -- find lib
        for _, value in pairs(result.linkdirs) do
            local dirbasename = path.basename(value)
            result.links[dirbasename] = path.join(value, "*")
        end
    end
    return result
end
