package controller

import (
	"github.com/codeready-toolchain/member-operator/pkg/configuration"
	"github.com/codeready-toolchain/member-operator/pkg/controller/idler"
	"github.com/codeready-toolchain/member-operator/pkg/controller/memberstatus"
	"github.com/codeready-toolchain/member-operator/pkg/controller/nstemplateset"
	"github.com/codeready-toolchain/member-operator/pkg/controller/useraccount"
	"github.com/codeready-toolchain/member-operator/pkg/controller/useraccountstatus"
	"github.com/codeready-toolchain/toolchain-common/pkg/controller/toolchaincluster"

	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/manager"
)

// addToManagerFuncs is a list of functions to add all Controllers to the Manager
var addToManagerFuncs []func(manager.Manager, *configuration.Config, client.Client) error

func init() {
	addToManagerFuncs = append(addToManagerFuncs, memberstatus.Add)
	addToManagerFuncs = append(addToManagerFuncs, useraccount.Add)
	addToManagerFuncs = append(addToManagerFuncs, useraccountstatus.Add)
	addToManagerFuncs = append(addToManagerFuncs, nstemplateset.Add)
	addToManagerFuncs = append(addToManagerFuncs, idler.Add)
}

// AddControllersToManager adds all Controllers to the Manager
func AddControllersToManager(m manager.Manager, config *configuration.Config, allNamespacesClient client.Client) error {
	if err := toolchaincluster.Add(m, config.GetToolchainClusterTimeout()); err != nil {
		return err
	}
	for _, f := range addToManagerFuncs {
		if err := f(m, config, allNamespacesClient); err != nil {
			return err
		}
	}
	return nil
}
