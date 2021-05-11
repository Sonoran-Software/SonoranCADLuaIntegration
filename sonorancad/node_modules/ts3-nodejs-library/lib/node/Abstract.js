"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Abstract = void 0;
class Abstract {
    constructor(parent, props, namespace) {
        this.namespace = namespace;
        this.propcache = { ...props };
        this.parent = parent;
    }
    /** retrieves the namespace of this class */
    getNameSpace() {
        return this.namespace;
    }
    /** returns JSONifyable data */
    toJSON(includeNameSpace = true) {
        const res = { ...this.propcache };
        if (includeNameSpace)
            res._namespace = this.getNameSpace();
        return res;
    }
    /**
     * retrieves a single property value by the given name
     * @param name the name from where the value should be retrieved
     */
    getPropertyByName(name) {
        return this.propcache[name];
    }
    /** updates the cache with the given object */
    updateCache(props) {
        this.propcache = { ...this.propcache, ...props };
        return this;
    }
    /** returns the parent class */
    getParent() {
        return this.parent;
    }
}
exports.Abstract = Abstract;
//# sourceMappingURL=Abstract.js.map