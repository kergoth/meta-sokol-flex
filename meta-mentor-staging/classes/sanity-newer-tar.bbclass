inherit sanity

def new_check_tar_version(sanity_data):
    from distutils.version import LooseVersion
    status, result = oe.utils.getstatusoutput("tar --version")
    if status != 0:
        return "Unable to execute tar --version, exit code %s\n" % status
    version = result.split()[3]
    if LooseVersion(version) < LooseVersion("1.27"):
        return "Your version of tar is older than 1.27 and has bugs which will break builds. Please install a newer version of tar.\n"
    return None

python newer_tar () {
    ctx, g = bb.utils.get_context(), globals()
    ctx['check_tar_version'] = ctx['new_check_tar_version']
    g['check_tar_version'] = g['new_check_tar_version']
    d.setVar('check_tar_version', d.getVar('new_check_tar_version', False).replace('def new_', 'def '))
}
newer_tar[eventmask] = "bb.event.ConfigParsed"
addhandler newer_tar
