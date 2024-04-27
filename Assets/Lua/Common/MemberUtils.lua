local MemberUtils = {}
MemberUtils.mri = require("Common.MemoryReferenceInfo")
MemberUtils.snapIndex = 0
function MemberUtils:SnapShot()
    self.snapIndex = self.snapIndex + 1
    self.mri.m_cMethods.DumpMemorySnapshot("./", string.format("%s-snap", self.snapIndex), -1)
end

function MemberUtils:CompareSnapShot()
    self.mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, string.format("./LuaMemRefInfo-All-[%s-snap].txt", self.snapIndex), string.format("./LuaMemRefInfo-All-[%s-snap].txt", self.snapIndex - 1))
end

return MemberUtils