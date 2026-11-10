#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
char **process_envp;
extern char **environ;
extern char compose_locale_installed_tag[32];
uint32_t compose_locale_import_xcompose(const char *);
uint32_t compose_locale_load(const char *);
uint32_t compose_locale_lookup(uint32_t,uint32_t,const uint32_t *,uint32_t *);
uint32_t compose_locale_prefix(uint32_t,uint32_t,const uint32_t *);
uint32_t compose_locale_remove_pack(const char *);
static void need(int ok,const char *what){if(!ok){fprintf(stderr,"native XCompose test: %s\n",what);exit(1);}}
static void write_text(const char *p,const char *s){FILE *f=fopen(p,"wb");need(f!=NULL,"create fixture");need(fwrite(s,1,strlen(s),f)==strlen(s),"write fixture");need(fclose(f)==0,"close fixture");}
int main(void){
    char tmp[]="/tmp/nekoedit-xcompose-ui-XXXXXX",*home=mkdtemp(tmp);
    char src[512],app[512],loc[768],pack[1024],sym[512],inc[512];
    char common[512],nested[512],include_src[512],include_pack[1024];
    char unsafe_src[512],unsafe_pack[1024],linked_include[512],linked_src[512];
    char cycle_src[512],cycle_child[512],cycle_pack[1024];
    char depth_src[512],depth_pack[1024],depth_path[512],depth_name[64],depth_next[64],depth_body[128];
    char expansion_src[512],expansion_pack[1024],expansion_common[512],expansion_content[4096];
    char system_root[512],locale_dir[768],locale_file[1024],iso_dir[768],iso_file[1024];
    char compose_dir[768],alias_dir[768],alias_file[1024],alias_src[512],alias_pack[1024];
    char home_dir[512],home_file[768],system_src[512],system_pack[1024];
    char traversal_src[512],traversal_pack[1024],macro_link_src[512],macro_link_pack[1024];
    char macro_link[1024],macro_dir_link[768],macro_dir_src[512],macro_dir_pack[1024];
    char c_locale_src[512],c_locale_pack[1024];
    struct stat st;uint32_t in[4],out[8],n,depth_i,expansion_i,expansion_len;
    const char *rules=
      "# In-app native import test\n"
      "<Multi_key> <o> <c> : \"©\"\n"
      "<Multi_key> <o> <c> : \"Neko\"\n"
      "<Multi_key> <n> <e> <k> : \"Neko\"\n"
      "<Multi_key> <t> <e> <s> <t> : \"TEST\"\n"
      "<Multi_key> <space> <quotedbl> : \"ASCII\"\n"
      "<Multi_key> <e> <x> : \"\\xC3\\xA9\"\n"
      "<Multi_key> <u> <x> : \"\\u03A9\"\n"
      "<Multi_key> <a> <m> : \"A\\u0301\"\n"
      "<Multi_key> <a> <e> : \"short\"\n"
      "<Multi_key> <a> <e> <x> : \"long\"\n"
      "<dead_acute> <a> : \"á\"\n"
      "<dead_grave> <e> : \"è\"\n";
    need(home!=NULL,"mkdtemp");
    need(setenv("HOME",home,1)==0,"set HOME");
    process_envp=environ;
    snprintf(src,sizeof(src),"%s/nekoedit-test.XCompose",home);write_text(src,rules);
    need(compose_locale_import_xcompose(src)==1,"valid file rejected");
    need(strcmp(compose_locale_installed_tag,"nekoedit-test.UTF-8")==0,"tag from filename");
    snprintf(app,sizeof(app),"%s/.nekoedit",home);
    snprintf(loc,sizeof(loc),"%s/locales",app);
    snprintf(pack,sizeof(pack),"%s/nekoedit-test.UTF-8.nlp",loc);
    need(stat(app,&st)==0&&(st.st_mode&0777)==0700,"app directory mode");
    need(stat(loc,&st)==0&&(st.st_mode&0777)==0700,"locale directory mode");
    need(stat(pack,&st)==0&&S_ISREG(st.st_mode)&&(st.st_mode&0777)==0600,"pack file/mode");
    need(compose_locale_load("nekoedit-test.UTF-8")==1,"runtime rejected generated pack");
    in[0]='o';in[1]='c';n=compose_locale_lookup(0,2,in,out);
    need(n==4&&out[0]=='N'&&out[3]=='o',"later duplicate override");
    in[0]='n';in[1]='e';in[2]='k';n=compose_locale_lookup(0,3,in,out);
    need(n==4&&out[0]=='N'&&out[3]=='o',"three-symbol sequence");
    in[0]='t';in[1]='e';in[2]='s';in[3]='t';n=compose_locale_lookup(0,4,in,out);
    need(n==4&&out[0]=='T'&&out[3]=='T',"four-symbol sequence");
    in[0]=0x20;in[1]=0x22;n=compose_locale_lookup(0,2,in,out);
    need(n==5&&out[0]=='A'&&out[4]=='I',"named ASCII keysyms");
    in[0]='e';in[1]='x';n=compose_locale_lookup(0,2,in,out);
    need(n==1&&out[0]==0xe9,"hex byte escape");
    in[0]='u';in[1]='x';n=compose_locale_lookup(0,2,in,out);
    need(n==1&&out[0]==0x3a9,"Unicode scalar escape");
    in[0]='a';in[1]='m';n=compose_locale_lookup(0,2,in,out);
    need(n==2&&out[0]=='A'&&out[1]==0x301,"multi-scalar output");
    in[0]=0x301;in[1]='a';n=compose_locale_lookup(1,2,in,out);
    need(n==1&&out[0]==0xe1,"dead-key namespace");
    in[0]='a';in[1]='e';
    need(compose_locale_lookup(0,2,in,out)==0&&compose_locale_prefix(0,2,in)==1,"short prefix removed");
    need(compose_locale_import_xcompose(src)==0&&stat(pack,&st)==0,"refused overwrite");
    snprintf(sym,sizeof(sym),"%s/symlink.XCompose",home);
    need(symlink(src,sym)==0,"make symlink");need(compose_locale_import_xcompose(sym)==0,"symlink source refused");
    snprintf(inc,sizeof(inc),"%s/include.XCompose",home);
    write_text(inc,"include \"%L\"\n<Multi_key> <a> <b> : \"x\"\n");
    need(setenv("NEKOEDIT_XCOMPOSE_SYSTEM_ROOT","/nekoedit-missing-system-root",1)==0,
         "set missing system root");
    process_envp=environ;
    need(compose_locale_import_xcompose(inc)==0,
         "%L with a missing system locale root did not fail closed");

    /* %L follows the process locale; %S and %H are confined to their roots. */
    snprintf(system_root,sizeof(system_root),"%s/xorg-locale",home);
    need(mkdir(system_root,0700)==0,"create system locale root");
    snprintf(locale_dir,sizeof(locale_dir),"%s/en_US.UTF-8",system_root);
    need(mkdir(locale_dir,0700)==0,"create locale directory");
    snprintf(iso_dir,sizeof(iso_dir),"%s/iso8859-1",system_root);
    need(mkdir(iso_dir,0700)==0,"create system include subdirectory");
    snprintf(locale_file,sizeof(locale_file),"%s/Compose",locale_dir);
    write_text(locale_file,
        "<Multi_key> <s> <y> : \"System\"\n"
        "include \"%S/iso8859-1/Compose\"\n");
    snprintf(iso_file,sizeof(iso_file),"%s/Compose",iso_dir);
    write_text(iso_file,
        "<Multi_key> <i> <s> : \"ISO\"\n"
        "<Multi_key> <c> <l> : \"C locale\"\n");
    snprintf(compose_dir,sizeof(compose_dir),"%s/compose.dir",system_root);
    write_text(compose_dir,
        "XCOMM locale compose mapping test\n"
        "en_US.UTF-8/Compose: en_US.UTF-8\n"
        "el_GR.UTF-8/Compose: el_CY.UTF-8\n"
        "iso8859-1/Compose: C\n");
    snprintf(home_dir,sizeof(home_dir),"%s/.XCompose.d",home);
    need(mkdir(home_dir,0700)==0,"create home include directory");
    snprintf(home_file,sizeof(home_file),"%s/personal.XCompose",home_dir);
    write_text(home_file,"<Multi_key> <h> <m> : \"Home\"\n");
    snprintf(system_src,sizeof(system_src),"%s/nekoedit-system.XCompose",home);
    snprintf(system_pack,sizeof(system_pack),"%s/nekoedit-system.UTF-8.nlp",loc);
    write_text(system_src,
        "include \"%L\"\n"
        "include \"%H/.XCompose.d/personal.XCompose\"\n");
    need(setenv("NEKOEDIT_XCOMPOSE_SYSTEM_ROOT",system_root,1)==0,
         "set synthetic system root");
    need(setenv("LC_ALL","en_US.UTF-8",1)==0,"set process character locale");
    process_envp=environ;
    need(compose_locale_import_xcompose(system_src)==1,
         "%L/%S/%H include tree was not imported");
    need(strcmp(compose_locale_installed_tag,"nekoedit-system.UTF-8")==0,
         "macro include pack tag was incorrect");
    need(compose_locale_load("nekoedit-system.UTF-8")==1,
         "runtime rejected macro-include pack");
    in[0]='s';in[1]='y';n=compose_locale_lookup(0,2,in,out);
    need(n==6&&out[0]=='S'&&out[5]=='m',"%L locale file was not expanded");
    in[0]='i';in[1]='s';n=compose_locale_lookup(0,2,in,out);
    need(n==3&&out[0]=='I'&&out[2]=='O',"%S nested system path was not expanded");
    in[0]='h';in[1]='m';n=compose_locale_lookup(0,2,in,out);
    need(n==4&&out[0]=='H'&&out[3]=='e',"%H home path was not expanded");
    need(compose_locale_remove_pack("nekoedit-system.UTF-8")==1,
         "could not remove macro-include pack");

    snprintf(alias_dir,sizeof(alias_dir),"%s/el_GR.UTF-8",system_root);
    need(mkdir(alias_dir,0700)==0,"create mapped locale directory");
    snprintf(alias_file,sizeof(alias_file),"%s/Compose",alias_dir);
    write_text(alias_file,"<Multi_key> <e> <c> : \"Greek alias\"\n");
    snprintf(alias_src,sizeof(alias_src),"%s/nekoedit-locale-alias.XCompose",home);
    snprintf(alias_pack,sizeof(alias_pack),"%s/nekoedit-locale-alias.UTF-8.nlp",loc);
    write_text(alias_src,"include \"%L\"\n");
    need(setenv("LC_ALL","el_CY.UTF-8",1)==0,"set aliased process locale");
    process_envp=environ;
    need(compose_locale_import_xcompose(alias_src)==1,
         "%L did not resolve locale through compose.dir");
    need(compose_locale_load("nekoedit-locale-alias.UTF-8")==1,
         "runtime rejected compose.dir alias pack");
    in[0]='e';in[1]='c';n=compose_locale_lookup(0,2,in,out);
    need(n==11&&out[0]=='G'&&out[10]=='s',
         "%L alias did not load mapped el_GR Compose file");
    need(compose_locale_remove_pack("nekoedit-locale-alias.UTF-8")==1,
         "could not remove compose.dir alias pack");

    snprintf(c_locale_src,sizeof(c_locale_src),"%s/nekoedit-c-locale.XCompose",home);
    snprintf(c_locale_pack,sizeof(c_locale_pack),"%s/nekoedit-c-locale.UTF-8.nlp",loc);
    write_text(c_locale_src,"include \"%L\"\n");
    need(setenv("LC_ALL","C",1)==0,"set C process locale");
    process_envp=environ;
    need(compose_locale_import_xcompose(c_locale_src)==1,
         "%L did not resolve the C locale through compose.dir");
    need(compose_locale_load("nekoedit-c-locale.UTF-8")==1,
         "runtime rejected C-locale compose.dir pack");
    in[0]='c';in[1]='l';n=compose_locale_lookup(0,2,in,out);
    need(n==8&&out[0]=='C'&&out[7]=='e',
         "%L C locale did not load its mapped Compose file");
    need(compose_locale_remove_pack("nekoedit-c-locale.UTF-8")==1,
         "could not remove C-locale pack");

    snprintf(traversal_src,sizeof(traversal_src),"%s/nekoedit-traversal.XCompose",home);
    snprintf(traversal_pack,sizeof(traversal_pack),"%s/nekoedit-traversal.UTF-8.nlp",loc);
    write_text(traversal_src,
        "include \"%S/../outside.XCompose\"\n"
        "<Multi_key> <t> <r> : \"traversal\"\n");
    need(compose_locale_import_xcompose(traversal_src)==0,
         "%S parent traversal was followed");
    need(access(traversal_pack,F_OK)!=0,
         "%S traversal rejection left a partial pack");

    snprintf(macro_link,sizeof(macro_link),"%s/linked.XCompose",iso_dir);
    need(symlink(iso_file,macro_link)==0,"create macro include file symlink");
    snprintf(macro_link_src,sizeof(macro_link_src),"%s/nekoedit-macro-link.XCompose",home);
    snprintf(macro_link_pack,sizeof(macro_link_pack),"%s/nekoedit-macro-link.UTF-8.nlp",loc);
    write_text(macro_link_src,"include \"%S/iso8859-1/linked.XCompose\"\n");
    need(compose_locale_import_xcompose(macro_link_src)==0,
         "%S file symlink was followed");
    need(access(macro_link_pack,F_OK)!=0,
         "%S file-symlink rejection left a partial pack");

    snprintf(macro_dir_link,sizeof(macro_dir_link),"%s/iso-alias",system_root);
    need(symlink(iso_dir,macro_dir_link)==0,"create macro include directory symlink");
    snprintf(macro_dir_src,sizeof(macro_dir_src),"%s/nekoedit-macro-dir-link.XCompose",home);
    snprintf(macro_dir_pack,sizeof(macro_dir_pack),"%s/nekoedit-macro-dir-link.UTF-8.nlp",loc);
    write_text(macro_dir_src,"include \"%S/iso-alias/Compose\"\n");
    need(compose_locale_import_xcompose(macro_dir_src)==0,
         "%S intermediate directory symlink was followed");
    need(access(macro_dir_pack,F_OK)!=0,
         "%S directory-symlink rejection left a partial pack");

    /* Safe includes are sibling-only, depth-first, and preserve textual order.
     * A repeated include after a later parent rule must apply again. */
    snprintf(common,sizeof(common),"%s/common.XCompose",home);
    snprintf(nested,sizeof(nested),"%s/nested.XCompose",home);
    snprintf(include_src,sizeof(include_src),"%s/nekoedit-include.XCompose",home);
    snprintf(include_pack,sizeof(include_pack),"%s/nekoedit-include.UTF-8.nlp",loc);
    write_text(nested,"<Multi_key> <n> <e> : \"Nested\"\n");
    write_text(common,
        "<Multi_key> <o> <c> : \"included\"\n"
        "<Multi_key> <i> <n> : \"Included\"\n"
        "include \"nested.XCompose\"\n");
    write_text(include_src,
        "<Multi_key> <o> <c> : \"before\"\n"
        "include \"common.XCompose\"\n"
        "<Multi_key> <o> <c> : \"after\"\n"
        "include \"common.XCompose\"\n");
    need(compose_locale_import_xcompose(include_src)==1,
         "safe sibling/nested includes did not import");
    need(strcmp(compose_locale_installed_tag,"nekoedit-include.UTF-8")==0,
         "included pack tag was incorrect");
    need(stat(include_pack,&st)==0&&(st.st_mode&0777)==0600,
         "included pack was not written privately");
    need(compose_locale_load("nekoedit-include.UTF-8")==1,
         "runtime rejected pack generated from safe includes");
    in[0]='o';in[1]='c';n=compose_locale_lookup(0,2,in,out);
    need(n==8&&out[0]=='i'&&out[7]=='d',
         "repeated include did not override later parent rule in textual order");
    in[0]='i';in[1]='n';n=compose_locale_lookup(0,2,in,out);
    need(n==8&&out[0]=='I'&&out[7]=='d',
         "sibling include rule was not expanded");
    in[0]='n';in[1]='e';n=compose_locale_lookup(0,2,in,out);
    need(n==6&&out[0]=='N'&&out[5]=='d',
         "nested sibling include was not expanded");
    need(compose_locale_remove_pack("nekoedit-include.UTF-8")==1,
         "could not remove safe-include pack");

    snprintf(unsafe_src,sizeof(unsafe_src),"%s/nekoedit-unsafe.XCompose",home);
    snprintf(unsafe_pack,sizeof(unsafe_pack),"%s/nekoedit-unsafe.UTF-8.nlp",loc);
    write_text(unsafe_src,
        "include \"../nekoedit-test.XCompose\"\n"
        "<Multi_key> <a> <b> : \"unsafe\"\n");
    need(compose_locale_import_xcompose(unsafe_src)==0,
         "parent-directory include was not rejected");
    need(access(unsafe_pack,F_OK)!=0,
         "parent-directory include left a partial pack");

    snprintf(linked_include,sizeof(linked_include),"%s/common-link.XCompose",home);
    snprintf(linked_src,sizeof(linked_src),"%s/nekoedit-link.XCompose",home);
    need(symlink(common,linked_include)==0,"could not create include symlink");
    write_text(linked_src,"include \"common-link.XCompose\"\n");
    need(compose_locale_import_xcompose(linked_src)==0,
         "symlinked sibling include was followed");

    snprintf(cycle_src,sizeof(cycle_src),"%s/nekoedit-cycle.XCompose",home);
    snprintf(cycle_child,sizeof(cycle_child),"%s/cycle-child.XCompose",home);
    snprintf(cycle_pack,sizeof(cycle_pack),"%s/nekoedit-cycle.UTF-8.nlp",loc);
    write_text(cycle_src,"include \"cycle-child.XCompose\"\n"
                         "<Multi_key> <c> <y> : \"cycle\"\n");
    write_text(cycle_child,"include \"nekoedit-cycle.XCompose\"\n");
    need(compose_locale_import_xcompose(cycle_src)==0,
         "active include cycle was not rejected");
    need(access(cycle_pack,F_OK)!=0,
         "include cycle left a partial pack");

    snprintf(expansion_src,sizeof(expansion_src),"%s/nekoedit-expand.XCompose",home);
    snprintf(expansion_pack,sizeof(expansion_pack),"%s/nekoedit-expand.UTF-8.nlp",loc);
    snprintf(expansion_common,sizeof(expansion_common),"%s/expand-common.XCompose",home);
    write_text(expansion_common,"<Multi_key> <e> <x> : \"expanded\"\n");
    {
        const char include_line[] = "include \"expand-common.XCompose\"\n";
        expansion_len = 0;
        for(expansion_i=0;expansion_i<65u;++expansion_i){
            memcpy(expansion_content+expansion_len,include_line,sizeof(include_line)-1u);
            expansion_len += (uint32_t)(sizeof(include_line)-1u);
        }
        expansion_content[expansion_len]=0;
        write_text(expansion_src,expansion_content);
    }
    need(compose_locale_import_xcompose(expansion_src)==0,
         "more than 64 include expansions were accepted");
    need(access(expansion_pack,F_OK)!=0,
         "include expansion limit left a partial pack");

    snprintf(depth_src,sizeof(depth_src),"%s/nekoedit-deep.XCompose",home);
    snprintf(depth_pack,sizeof(depth_pack),"%s/nekoedit-deep.UTF-8.nlp",loc);
    write_text(depth_src,"include \"depth-00.XCompose\"\n");
    for(depth_i=0;depth_i<=16u;++depth_i){
        snprintf(depth_name,sizeof(depth_name),"depth-%02u.XCompose",depth_i);
        snprintf(depth_path,sizeof(depth_path),"%s/%s",home,depth_name);
        if(depth_i<16u){
            snprintf(depth_next,sizeof(depth_next),"depth-%02u.XCompose",depth_i+1u);
            snprintf(depth_body,sizeof(depth_body),"include \"%s\"\n",depth_next);
        }else{
            snprintf(depth_body,sizeof(depth_body),"<Multi_key> <d> <p> : \"deep\"\n");
        }
        write_text(depth_path,depth_body);
    }
    need(compose_locale_import_xcompose(depth_src)==0,
         "include recursion exceeded the configured depth limit");
    need(access(depth_pack,F_OK)!=0,
         "over-depth include tree left a partial pack");

    need(compose_locale_remove_pack("nekoedit-test.UTF-8")==1,"remove original imported pack");
    unlink(sym);unlink(src);unlink(inc);unlink(common);unlink(nested);unlink(include_src);
    unlink(unsafe_src);unlink(linked_include);unlink(linked_src);unlink(cycle_src);unlink(cycle_child);
    unlink(expansion_src);unlink(expansion_common);unlink(depth_src);
    unlink(system_src);unlink(c_locale_src);unlink(alias_src);unlink(traversal_src);
    unlink(macro_link_src);unlink(macro_dir_src);
    unlink(macro_link);unlink(macro_dir_link);unlink(home_file);
    unlink(locale_file);unlink(iso_file);unlink(compose_dir);unlink(alias_file);
    need(rmdir(home_dir)==0&&rmdir(locale_dir)==0&&rmdir(alias_dir)==0&&
         rmdir(iso_dir)==0&&rmdir(system_root)==0,"cleanup macro include directories");
    for(depth_i=0;depth_i<=16u;++depth_i){snprintf(depth_name,sizeof(depth_name),"depth-%02u.XCompose",depth_i);snprintf(depth_path,sizeof(depth_path),"%s/%s",home,depth_name);unlink(depth_path);}
    need(rmdir(loc)==0&&rmdir(app)==0&&rmdir(home)==0,"cleanup");
    puts("Native in-app XCompose import tests passed");
    return 0;
}
